teams <- c("Gryffindor", "Hufflepuff", "Slytherin")
inputDirs <- paste0("../Submissions/2019-05-05/", teams, "/")
outputDir <- "../Submissions/2019-05-05/Combined/"

dir.create(outputDir, showWarnings = FALSE)
for (predictionFileName in list.files(inputDirs[1], pattern = "prediction-[0-9]+\\.csv")) {
  fileNameWithoutTeam <- gsub("^[A-za-z]+", "", predictionFileName)
  allPredictionFiles <- list.files(inputDirs, fileNameWithoutTeam, full.names = TRUE)
  predictionsList <- lapply(allPredictionFiles, function(teamPredictionFile)
    read.csv(teamPredictionFile, sep = "+", quote = "")$fraud)
  prediction <- Reduce("+", x = predictionsList)
  prediction <- data.frame(fraud = as.integer(prediction  > length(inputDirs) / 2)) # majority
  write.csv(prediction, file = paste0(outputDir, "Combined", fileNameWithoutTeam),
            row.names = FALSE, quote = FALSE)
}
