dmcTrainData <- read.csv("data/train.csv", sep = "|", quote = "")

for (seedValue in 1:10) {
  set.seed(seedValue)
  target0Idx <- which(dmcTrainData$fraud == "0")
  target1Idx <- which(dmcTrainData$fraud == "1")
  trainTarget0 <- sample(target0Idx, size = round(0.8 * length(target0Idx)), replace = FALSE)
  trainTarget1 <- sample(target1Idx, size = round(0.8 * length(target1Idx)), replace = FALSE)
  trainData <- dmcTrainData[sort(c(trainTarget0, trainTarget1)), ]
  testData <- dmcTrainData[-c(trainTarget0, trainTarget1), ]
  output.file <- file(paste0("data/split-train-", seedValue, ".csv"), "wb") # necessary on Windows
  write.table(trainData, file = output.file, quote = FALSE, sep = "|",
      dec = ".", row.names = FALSE, eol = "\n")
  close(output.file)
  output.file <- file(paste0("data/split-test-", seedValue, ".csv"), "wb")
  write.table(testData[, which(colnames(testData) != "fraud")], file = output.file,
      quote = FALSE, sep = "|", dec = ".", row.names = FALSE, eol = "\n")
  close(output.file)
  output.file <- file(paste0("data/split-test-labels-", seedValue, ".csv"), "wb")
  write.table(data.frame(fraud = testData$fraud), file = output.file,
      quote = FALSE, sep = "|", dec = ".", row.names = FALSE, eol = "\n")
  close(output.file)
}
