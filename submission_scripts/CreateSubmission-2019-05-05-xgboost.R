library(data.table)
# library(xgboost) # should be installed, but we use functions only with package name

source("UtilityFunctions.R")

inputPath <- "data/"
dateString <- "2019-05-05"
outputPath <- paste0("../Submissions/", dateString, "/Slytherin/")

if (!dir.exists(outputPath)) {
  dir.create(outputPath, showWarnings = FALSE, recursive = TRUE)
}
for (inputTestFile in list.files(inputPath, pattern = "split-test-[0-9]+\\.csv", full.names = TRUE)) {
  # Read in
  trainData <- read.csv(gsub("test", "train", inputTestFile), sep = "|", quote = "")
  testData <- read.csv(inputTestFile, sep = "|", quote = "")
  
  # Pre-process and engineer features
  trainData <- engineerFeatures(trainData)
  testData <- engineerFeatures(testData)
  
  # Train model
  xgbTrainPredictors <- Matrix::sparse.model.matrix(~ ., data = trainData[, -"fraud"])[, -1]
  xgbTrainData <- xgboost::xgb.DMatrix(data = xgbTrainPredictors, label = trainData$fraud)
  xgbTestPredictors <- Matrix::sparse.model.matrix(~ ., data = testData)[, -1]
  xgbModel <- xgboost::xgb.train(data = xgbTrainData, nrounds = 50,
      params = list(objective = "binary:logistic", nthread = 4))
  
  # Predict
  trainPrediction <- predict(xgbModel, newdata = xgbTrainPredictors)
  testPrediction <- predict(xgbModel, newdata = xgbTestPredictors)
  threshold <- optimize(function(x) {
    dmcScore(actual = trainData$fraud, prediction = as.integer(trainPrediction >= x))
  }, lower = 0, upper = 1, maximum = TRUE)$maximum
  solution <- data.frame(fraud = as.integer(testPrediction >= threshold))
  
  # Write solution
  seedString <- regmatches(inputTestFile, regexpr("[0-9]+.csv$", inputTestFile))
  write.csv(solution, file = paste0(outputPath, "Slytherin-", dateString, "-prediction-", seedString),
            row.names = FALSE, quote = FALSE)
}
