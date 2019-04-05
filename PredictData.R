source("UtilityFunctions.R")

library(data.table)

dmcTrainData <- data.table(read.csv("data/train.csv", sep = "|", quote = ""))

# Train-test split
set.seed(25)
target0Idx <- dmcTrainData[, which(fraud == "0")]
target1Idx <- dmcTrainData[, which(fraud == "1")]
trainTarget0 <- sample(target0Idx, size = round(0.8 * length(target0Idx)), replace = FALSE)
trainTarget1 <- sample(target1Idx, size = round(0.8 * length(target1Idx)), replace = FALSE)
trainData <- dmcTrainData[sort(c(trainTarget0, trainTarget1))]
testData <- dmcTrainData[-c(trainTarget0, trainTarget1)]

# Baseline: Guess "0" (less costly default class)
dmcScore(actual = testData$fraud, prediction = rep(0, nrow(testData)))
