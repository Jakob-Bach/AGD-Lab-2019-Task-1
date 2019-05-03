# Task 1 (DMC) - Supervisor Repo

## Course-Internal Test Data

### Splits

The splits for the students can be created with the R script `SplitForStudents.R`.
For this purpose, the DMC file `train.csv` has to be placed in a folder `data/` (relative to the script).
No special R packages are required.

### Scoring

The predictions of the students can be scored with the R script `ScoreStudents.R`.
The path to the prediction files has to be set for each scoring procedure (team and week).
If the naming scheme of the prediction files or the path/naming scheme of the ground truth (as defined in `SplitForStudents.R`) changes, further adaptations might be necessary.
No special R packages are required.

## Slytherin submissions

Code to reproduce Slytherin submission scores - as presented in the joint meetings - can be found in the directory `submission_scrips/`.

- `CreateSubmission-2019-04-14-Baseline.R`: predict `0` (majority and less costly class) for each test object
- `CreateSubmission-2019-04-21-DecisionTree.R`: feature creation, untuned `rpart`, threshold moving based on DMC score
- `CreateSubmission-2019-04-28-DecisionTree2.R`: feature creation, untuned `xgboost` with 1 tree, threshold moving
- `CreateSubmission-2019-05-05-xgboost.R`: feature creation, untuned `xgboost` with 50 trees, threshold moving
- `CreateSubmission-2019-05-05-xgboost-tuned.R`: feature creation, `xgboost` with number of trees tuned, threshold moving
