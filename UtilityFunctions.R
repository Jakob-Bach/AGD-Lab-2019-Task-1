dmcScore <- function(actual, prediction) {
  tp <- sum(actual == "1" & prediction == "1")
  fp <- sum(actual == "0" & prediction == "1")
  fn <- sum(actual == "1" & prediction == "0")
  return(-5 * fn + 5 * tp - 25 * fp)
}

xgbDMCScore <- function(preds, dtrain) {
  return(list(metric = "DMC score",
              value = dmcScore(actual = xgboost::getinfo(dtrain, "label"),
                               prediction = as.integer(preds >= 0.5))))
}
