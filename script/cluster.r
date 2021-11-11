library(data.table)
library(svglite)
args <-  commandArgs(trailingOnly=TRUE)
in_f <- args[1]
out_f  <- args[2]

data <- data.frame(fread(in_f, header = T, sep = "\t", data.table = FALSE),
                   row.names = 1)
# subtract median for normalization
nor <- sweep(data, 1, apply(data, 1, median))

# use most variable 1000 genes
targets <- data[order(apply(data, 1, sd), decreasing = T), ][1:1000, ]
cortable <- cor(targets)

# clustering by Ward
## use 1-cortable as a distance matrix,
## because smaller value should mean closer distance
hc_result <- hclust(1 - as.dist(cortable), method = "ward.D2")
# output
svglite(out_f, width = 120, height = 30)
plot(hc.result)
dev.off()

## plotting the result converted to dendrogram with horiz=T displays horizontally,
## but has a problem that labels are not fully shown.
# svglite("hclust1.svg", width = 60, height = 120)
# plot(as.dendrogram(hc.result), horiz = TRUE)
# dev.off()
