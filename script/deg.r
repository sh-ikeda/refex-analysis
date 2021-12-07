library(optparse)

optslist <- list(
    make_option("--g1",
                type = "character",
                help = "Comma separated list of sample group IDs for group 1",
                default = "",
                dest = "group1"),
    make_option("--g2",
                type = "character",
                help = "Comma separated list of sample group IDs for group 2",
                default = "",
                dest = "group2"),
    make_option(c("-i", "--input"),
                type = "character",
                help = "Path to count table file",
                default = "",
                dest = "count_table"),
    make_option(c("-m", "--mapping"),
                type = "character",
                help = "Path to sample ID mapping table file",
                default = "",
                dest = "mapping_table"),
    make_option(c("-o", "--output"),
                type = "character",
                help = "File name of output table",
                default = "",
                dest = "output_filename"),
    make_option(c("-d", "--debug"),
                action = "store_true",
                type = "logical",
                help = "debug mode",
                default = FALSE,
                dest = "debug"),
    make_option("--l1",
                type = "character",
                help = "Label for group 1",
                default = "",
                dest = "label1"),
    make_option("--l2",
                type = "character",
                help = "Label for group 2",
                default = "",
                dest = "label2")
    )
parser <- OptionParser(option_list = optslist,
                       description = "--g1, --g2, -i, -m, and -o are required")
opts <- parse_args(parser)

if (any(c(opts$group1, opts$group2,
          opts$count_table, opts$mapping_table, opts$output_filename) == "")) {
    print_help(parser)
    Exit(1)
}
if (opts$label1 == "")
    opts$label1 <- opts$group1
if (opts$label2 == "")
    opts$label2 <- opts$group2

library(edgeR)
library(data.table)

message("Loading input tables...")
count <- data.frame(fread(opts$count_table, sep = "\t",
                          data.table = F, header = T, check.names = F),
                    row.names = 1)
mapping  <- read.table(opts$mapping_table, sep = "\t", header = T)

g1_group_ids <- strsplit(opts$group1, ",")[[1]]
g2_group_ids <- strsplit(opts$group2, ",")[[1]]
group_ids <- c(g1_group_ids, g2_group_ids)
for (i in seq_len(length(group_ids))) {
    if (!any(mapping[, 1] == group_ids[i])) {
        stop(group_ids[i], " is not found on the mapping table.")
    }
}

g1_re <- gsub(",", "|", opts$group1)
g1_eachsample_ids <- mapping[regexpr(g1_re, mapping[, 1]) > 0, 2]
g1_eachsample_re <- paste(g1_eachsample_ids, collapse = "|")
g2_re <- gsub(",", "|", opts$group2)
g2_eachsample_ids <- mapping[regexpr(g2_re, mapping[, 1]) > 0, 2]
g2_eachsample_re <- paste(g2_eachsample_ids, collapse = "|")
eachsample_re <- paste(g1_eachsample_re, g2_eachsample_re, sep = "|")

count_reduced <- count[, regexpr(eachsample_re, colnames(count)) > 0]

# assign group names to the columns of the reduced table
group <- factor(
    ifelse(regexpr(g1_eachsample_re, colnames(count_reduced)) > 0,
           opts$label1,
           ifelse(regexpr(g2_eachsample_re, colnames(count_reduced)) > 0,
                  opts$label2, F)))
count_matrix <- as.matrix(count_reduced)
if (opts$debug) {
    print(count_reduced[1:3, ])
    print(group)
}

message("Calculating DEG...")
t <- Sys.time()
d <- DGEList(counts = count_matrix, group = group)
d <- calcNormFactors(d)
d <- estimateCommonDisp(d)
d <- estimateTagwiseDisp(d)
result <- exactTest(d)
message("calculation time: ", Sys.time() - t)

table <- as.data.frame(topTags(result, n = nrow(count)))
write.table(table, file = opts$output_filename, col.names = T,
            row.names = T, sep = "\t", quote = FALSE)
