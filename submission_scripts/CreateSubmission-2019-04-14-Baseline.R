inputPath <- "data/"
outputPath <- paste0("../Submissions/2019-04-14/Slytherin/")

if (!dir.exists(outputPath)) {
  dir.create(outputPath, showWarnings = FALSE, recursive = TRUE)
}
for (inputTestFile in list.files(inputPath, pattern = "split-test-[0-9]+\\.csv", full.names = TRUE)) {
  testData <- read.csv(inputTestFile, sep = "|", quote = "")
  solution <- data.frame(fraud = rep(0, times = nrow(testData)))
  seedString <- regmatches(inputTestFile, regexpr("[0-9]+.csv$", inputTestFile))
  write.csv(solution, file = paste0(outputPath, "Slytherin-2019-04-14-prediction-", seedString),
            row.names = FALSE, quote = FALSE)
}
