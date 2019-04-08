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

## Baseline Submission

`CreateBaselineSubmission.R` reads all test data split files from a directory and creates valid submission files by predicting `O` for each test object.
