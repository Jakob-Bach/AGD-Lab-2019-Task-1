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

# Threshold moving evaluation (several models, call this after prediciting)
threshold <- optimize(function(x) {
  dmcScore(actual = trainData$fraud, prediction = as.integer(trainPrediction >= x))
}, lower = 0, upper = 1, maximum = TRUE)$maximum
dmcScore(actual = testData$fraud, prediction = as.integer(testPrediction >= threshold))
table(actual = testData$fraud, prediction = as.integer(testPrediction >= threshold))
ggplot(data = data.table(Threshold = seq(from = 0.01, to = 1, by = 0.01),
    dmcScore = sapply(seq(from = 0.01, to = 1, by = 0.01), function(x)
      dmcScore(actual = testData$fraud, prediction = as.integer(testPrediction >= x))))) +
  geom_line(aes(x = Threshold, y = dmcScore)) +
  geom_vline(xintercept = threshold, color = "red")

# Naive Bayes [e1071]
naiveBayesModel <- e1071::naiveBayes(formula = fraud ~ ., data = trainData)
trainPrediction <- predict(naiveBayesModel, newdata = trainData, type = "raw")[, 2]
testPrediction <- predict(naiveBayesModel, newdata = testData, type = "raw")[, 2]
