message("[", Sys.time(), "] Loading libraries")
suppressMessages(library(TCC))
suppressMessages(library(data.table))

args <-  commandArgs(trailingOnly=TRUE)
input_logtpm <- args[1]
input_res <- args[2]
output_filename  <- args[3]

message("[", Sys.time(), "] Reading the input table")
logtpm_whole <- data.frame(fread(input_logtpm,
                                 header = TRUE,
                                 sep = "\t",
                                 quote = ""),
                           row.names = 1)
res <- read.table(input_res, sep = "\t")
logtpm_target <- logtpm_whole[, res[, 1]]
tpm_target  <- 2^logtpm_target - 1

message("[", Sys.time(), "] Calculating ROKU")
result <- ROKU(logtpm_target)
tau <- apply(1-tpm_target/apply(tpm_target, 1, max), 1, sum)/(ncol(tpm_target)-1)
outlier <- result$outlier
modH <- result$modH
ranking <- result$rank
geneId <- rownames(logtpm_target)
tmp <- cbind(geneId, modH, ranking, tau, outlier)
message("[", Sys.time(), "] Writing")
write.table(tmp, output_filename, sep = "\t", append = F, quote = F, row.names = F)
message("[", Sys.time(), "] Done")

