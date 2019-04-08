source("UtilityFunctions.R")

library(data.table)
library(ggplot2)

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

# Decision tree [rpart]
rpartModel <- rpart::rpart(formula = fraud ~ ., data = trainData, method = "class",
    control = list(cp = 0.05))
trainPrediction <- predict(rpartModel, newdata = trainData, type = "prob")[, 2]
testPrediction <- predict(rpartModel, newdata = testData, type = "prob")[, 2]

rpartModel$variable.importance
rpart.plot::rpart.plot(rpartModel)

# Random forest [ranger]
rfModel <- ranger::ranger(formula = fraud ~ ., num.trees = 50, verbose = TRUE,
    data = trainData, probability = TRUE, importance = "impurity", seed = 25)
trainPrediction <- predict(rfModel, data = trainData, type = "response")$predictions[, 2]
testPrediction <- predict(rfModel, data = testData, type = "response")$predictions[, 2]

ranger::importance(rfModel)

# Boosted trees [xgboost]
xgbTrainPredictors <- Matrix::sparse.model.matrix(~ ., data = trainData[, -"fraud"])[, -1]
xgbTrainData <- xgboost::xgb.DMatrix(data = xgbTrainPredictors, label = trainData$fraud)
xgbTestPredictors <- Matrix::sparse.model.matrix(~ ., data = testData[, -"fraud"])[, -1]
xgbTestData <- xgboost::xgb.DMatrix(data = xgbTestPredictors, label = testData$fraud)
xgbModel <- xgboost::xgb.train(data = xgbTrainData, nrounds = 100, verbose = 2,
    watchlist = list(train = xgbTrainData, test = xgbTestData),
    params = list(objective = "binary:logistic", eval_metric = xgbDMCScore, nthread = 4))
trainPrediction <- predict(xgbModel, newdata = xgbTrainPredictors)
testPrediction <- predict(xgbModel, newdata = xgbTestPredictors)

ggplot(data = melt(data = xgbModel$evaluation_log, id.vars = "iter")) +
  geom_line(aes(x = iter, y = value, color = variable)) + ylab("DMC score")
xgbImportanceMatrix <- xgboost::xgb.importance(model = xgbModel)
xgboost::xgb.ggplot.importance(importance_matrix = xgbImportanceMatrix)
xgboost::xgb.plot.shap(data = xgbTrainPredictors, model = xgbModel, top_n = 2)
xgboost::xgb.plot.tree(model = xgbModel, trees = 0:2)
xgboost::xgb.plot.multi.trees(model = xgbModel) # all trees merged in one
xgboost::xgb.ggplot.deepness(model = xgbModel) # model complexity
