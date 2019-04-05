library(data.table)
library(ggplot2)

dmcTrainData <- data.table(read.csv("data/train.csv", sep = "|", quote = ""))
dmcTestData <- data.table(read.csv("data/test.csv", sep = "|", quote = ""))
dmcData <- rbind(dmcTrainData, dmcTestData, fill = TRUE)

# Compare train-test regarding density of (continuous) numeric attributes
for (attribute in c("totalScanTimeInSeconds", "grandTotal",
    "scannedLineItemsPerSecond", "valuePerSecond", "lineItemVoidsPerPosition")) {
  print(
    ggplot(dmcData[scannedLineItemsPerSecond < 1 & valuePerSecond < 1]) +
      geom_density(aes(x = get(attribute), fill = is.na(fraud)), alpha = .5) +
      xlab(attribute)
  )
}

# Compare train-test regarding frequency of integer attribute values
for (attribute in c("trustLevel", "lineItemVoids", "scansWithoutRegistration",
    "quantityModifications")) {
  print(
    ggplot(dmcData) +
      geom_bar(aes(x = get(attribute), y = ..prop.., fill = is.na(fraud)), position = "dodge") +
      xlab(attribute)
  )
}
