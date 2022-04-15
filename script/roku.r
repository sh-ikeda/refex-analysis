library(TCC)
#in_f <- "gene-samplegroup.tsv"
#out_f <- "roku_fantom5_human.tsv"
#in_f <- "testdata.tsv"
#out_f <- "testout.tsv"
args <-  commandArgs(trailingOnly=TRUE)
input_logtpm <- args[1]
input_res <- args[2]
output_filename  <- args[3]

message(Sys.time())
message("reading table")
logtpm_whole <- read.table(input_logtpm, header = TRUE, row.names = 1, sep = "\t", quote = "")
res <- read.table(input_res)
logtpm_target <- logtpm_whole[, res[, 1]]
tpm_target  <- 2^logtpm_target - 1

message(Sys.time())
message("calculating ROKU")
result <- ROKU(logtpm_target)
tau <- apply(1-tpm_target/apply(tpm_target, 1, max), 1, sum)/(ncol(tpm_target)-1)
outlier <- result$outlier
modH <- result$modH
ranking <- result$rank

#左端の列が遺伝子ID, 次にサンプル数分だけの列からなる「外れ値行列」、「modH」、「ranking」を結合してtmpに格納
tmp <- cbind(rownames(logtpm_target), outlier, modH, ranking, tau)
message(Sys.time())
message("writing table")
write.table(tmp, output_filename, sep = "\t", append = F, quote = F, row.names = F)
message(Sys.time())
