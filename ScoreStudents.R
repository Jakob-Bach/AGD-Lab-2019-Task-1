source("UtilityFunctions.R")

# Things that have to be adapted per week and group:
dateString <- "2019-04-14"
predictionBasePath <- paste0("../Submissions/", dateString, "/Gryffindor/")

# Get names of split files
truthFiles <- list.files("data/", pattern = "split-.*-labels-.*\\.csv", full.names = TRUE)
if (length(truthFiles) == 0) {
  stop("The ground truth files seem to have disappeared.")
}
if (length(list.files(predictionBasePath, pattern = "\\.csv")) != length(truthFiles)) {
  stop("Number of prediction and ground truth files differ.")
}

score <- 0 # will be averaged over splits
for (truthFileName in truthFiles) {
  seedString <- regmatches(truthFileName, regexpr("[0-9]+.csv$", truthFileName))
  predictionFileName <- list.files(predictionBasePath, full.names = TRUE,
      pattern = paste0(dateString, "-prediction-", seedString))
  if (length(predictionFileName) != 1) {
    stop(paste0("Zero or multiple matching prediction files found for \"", seedString, "\"."))
  }
  groundTruth <- read.csv(truthFileName)
  prediction <- read.csv(predictionFileName, sep = "+", quote = "") # causes files with row names or quoted values to fail later
  if (nrow(prediction) != nrow(groundTruth)) {
    stop("Number of observations wrong.")
  }
  if (ncol(prediction) != ncol(groundTruth)) {
    stop("Number of columns wrong.")
  }
  if (colnames(prediction) != colnames(groundTruth)) {
    stop("Column name wrong (quoted or wrong string).")
  }
  if (!is.numeric(prediction$fraud)) {
    stop("Data type wrong (might be quoted).")
  }
  if (any(prediction$fraud != 0 & prediction$fraud != 1)) {
    stop("Additional class labels.")
  }
  score <- score + dmcScore(actual = groundTruth$fraud, prediction = prediction$fraud) / nrow(groundTruth)
}
print(round(score / length(truthFiles), digits = 3))
