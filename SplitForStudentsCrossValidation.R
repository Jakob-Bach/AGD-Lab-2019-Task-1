dmcTrainData <- read.csv("data/train.csv", sep = "|", quote = "")

numFolds <- 10
seedValue <- 25
set.seed(seedValue)
target0Idx <- which(dmcTrainData$fraud == "0")
target1Idx <- which(dmcTrainData$fraud == "1")
foldTarget0Idx <- sample(rep(1:numFolds, length.out = length(target0Idx))) # integer sampling shuffles by default
foldTarget1Idx <- sample(rep(1:numFolds, length.out = length(target1Idx)))

for (i in 1:numFolds) {
  trainTarget0 <- target0Idx[foldTarget0Idx != i]
  trainTarget1 <- target1Idx[foldTarget1Idx != i]
  trainData <- dmcTrainData[sort(c(trainTarget0, trainTarget1)), ]
  testData <- dmcTrainData[-c(trainTarget0, trainTarget1), ]
  output.file <- file(paste0("data/split-train-", seedValue + i, ".csv"), "wb") # necessary on Windows
  write.table(trainData, file = output.file, quote = FALSE, sep = "|",
      dec = ".", row.names = FALSE, eol = "\n")
  close(output.file)
  output.file <- file(paste0("data/split-test-", seedValue + i, ".csv"), "wb")
  write.table(testData[, which(colnames(testData) != "fraud")], file = output.file,
      quote = FALSE, sep = "|", dec = ".", row.names = FALSE, eol = "\n")
  close(output.file)
  output.file <- file(paste0("data/split-test-labels-", seedValue + i, ".csv"), "wb")
  write.table(data.frame(fraud = testData$fraud), file = output.file,
      quote = FALSE, sep = "|", dec = ".", row.names = FALSE, eol = "\n")
  close(output.file)
}
