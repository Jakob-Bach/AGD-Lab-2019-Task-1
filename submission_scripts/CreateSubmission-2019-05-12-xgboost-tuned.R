library(data.table)
# library(doSNOW) # should be installed, but we use functions only with package name
library(foreach)
# library(xgboost) # should be installed, but we use functions only with package name

source("UtilityFunctions.R")

inputPath <- "data/"
dateString <- "2019-05-12"
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
  
  # Tune model with grid search
  paramGrid = data.table(nrounds = 2^(0:8)) # expand.grid() if more params
  computingCluster <- parallel::makeCluster(parallel::detectCores())
  doSNOW::registerDoSNOW(computingCluster)
  paramPerformance <- unlist(foreach(i = 1:nrow(paramGrid), .packages = c("data.table", "xgboost")) %dopar% {
    set.seed(25)
    ttarget0Idx <- which(trainData$fraud == "0")
    ttarget1Idx <- which(trainData$fraud == "1")
    ttrainTarget0 <- sample(ttarget0Idx, size = round(0.8 * length(ttarget0Idx)), replace = FALSE)
    ttrainTarget1 <- sample(ttarget1Idx, size = round(0.8 * length(ttarget1Idx)), replace = FALSE)
    ttrainData <- trainData[sort(c(ttrainTarget0, ttrainTarget1)), ]
    ttestData <- trainData[-c(ttrainTarget0, ttrainTarget1), ]
    
    xgbTTrainPredictors <- Matrix::sparse.model.matrix(~ ., data = ttrainData[, -"fraud"])[, -1]
    xgbTTrainData <- xgboost::xgb.DMatrix(data = xgbTTrainPredictors, label = ttrainData$fraud)
    xgbTTestPredictors <- Matrix::sparse.model.matrix(~ ., data = ttestData[, -"fraud"])[, -1]
    xgbTModel <- xgboost::xgb.train(data = xgbTTrainData, nrounds = paramGrid[i, nrounds],
        params = list(objective = "binary:logistic", nthread = 1))
    
    ttrainPrediction <- predict(xgbTModel, newdata = xgbTTrainPredictors)
    ttestPrediction <- predict(xgbTModel, newdata = xgbTTestPredictors)
    tthreshold <- optimize(function(x) {
      dmcScore(actual = ttrainData$fraud, prediction = as.integer(ttrainPrediction >= x))
    }, lower = 0, upper = 1, maximum = TRUE)$maximum
    return(dmcScore(actual = ttestData$fraud,
                    prediction = as.integer(ttestPrediction >= tthreshold)))
  })
  parallel::stopCluster(computingCluster)
  maxPerfIdx <- which.max(paramPerformance)
  
  # Train model with optimal hyperparameters
  xgbTrainPredictors <- Matrix::sparse.model.matrix(~ ., data = trainData[, -"fraud"])[, -1]
  xgbTrainData <- xgboost::xgb.DMatrix(data = xgbTrainPredictors, label = trainData$fraud)
  xgbTestPredictors <- Matrix::sparse.model.matrix(~ ., data = testData)[, -1]
  xgbModel <- xgboost::xgb.train(data = xgbTrainData, nrounds = paramGrid[maxPerfIdx, nrounds],
      params = list(objective = "binary:logistic", nthread = parallel::detectCores()))
  
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
