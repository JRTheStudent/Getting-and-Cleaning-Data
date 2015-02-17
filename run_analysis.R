## The requirements for this script provided within the course are as follows:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each
##    measurement.
## 3. Uses descriptive activity names to name the activities in the data set.
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set
##    with the average of each variable for each activity and each subject.

## TODO: Output

## Non-validated assumptions about the data:
## -All files in "files" exist and are readible (see example in "Setup steps.")
## -features.txt contains one numbered line corresponding to each variable
##    in X_{test, train}.txt
## -X_{test, train}.txt contain the same order and number of variables.
## -y_{test, train}.txt contain one line corresponding to each observation
##    in X_{test, train}.txt and each value is classified by a corresponding
##    label in activity_labels.txt
## -subject_{test, train}.txt contain one line corresponding to each observation
##    in X_{test, train}.txt

## Setup steps:
## if(!(file.exists("./data") & file.info("./data")$isdir)) dir.create("./data")
## download.file(
##     paste(
##          "https://d396qusza40orc.cloudfront.net/"
##         ,"getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
##         ,sep = ""
##     )
##     ,destfile = "./data/data.zip"
## )
## write(date(), file = "./data/date_downloaded.txt")
## unzip("./data/data.zip", exdir = "./data")

## Date downloaded: Sat Feb 14 06:53:52 2015

## Load libraries for use.  Note "plyr" needs to be loaded before "dplyr."

library(plyr)
library(dplyr)

## Create an environment for this script so other names assigned within do not
## clobber anything in the runtime Global Environment.

my <- new.env()

## Create a character vector of the files required for processing.

my$files <- c(
    "features"        = "./data/UCI HAR Dataset/features.txt"
    ,"activityLables" = "./data/UCI HAR Dataset/activity_labels.txt"
    ,"testData"       = "./data/UCI HAR Dataset/test/X_test.txt"
    ,"testActivity"   = "./data/UCI HAR Dataset/test/y_test.txt"
    ,"testSubject"    = "./data/UCI HAR Dataset/test/subject_test.txt"
    ,"trainData"      = "./data/UCI HAR Dataset/train/X_train.txt"
    ,"trainActivity"  = "./data/UCI HAR Dataset/train/y_train.txt"
    ,"trainSubject"   = "./data/UCI HAR Dataset/train/subject_train.txt"
)

## Requirement 1: Merge the test and training data sets.
## The {test, train}Data data sets both contain 561 variables with 2,947 and
## 7,352 observations, respectively.  Wrapping the read.tables with rbind
## 'stacks' the test data set atop the train data set, creating a data frame
## with 10,299 observations of 561 variables. Combining the data sets by
## 'stacking' in one step is more efficient but all subsequent 'stacked'
## actions _must_ proceed by 'stacking' test data atop train data to maintain
## coherence.

my$data <- rbind(
    read.table(my$files[["testData"]])
    ,read.table(my$files[["trainData"]])
)

## Requirement 4: Label the data set with descriptive variable names.
## The "features" files contains a numbered list of column names for the test
## and train data sets.  Extract values from column "V2" of "features" and
## assign to "names(my$data)."

names(my$data) <- as.character(read.table(my$files[["features"]])$V2)

## Requirement 2: Extract only mean and standard deviation measurements.
## Subselect columns with variable names containing the character strings
## "mean" and "std" (standard deviation), case-insensitively and in any position
## within the variable name.  As the requirements are not explicit and the
## inclusion of (potentially) superfluous variables does not affect required
## processing (the variables are independent in the processing) it is preferable
## to err on the side of broader inclusivity.

my$data <- my$data[, grep("mean|std", names(my$data), ignore.case = T)]

## Append new column "subject" to "data" by rbind on the {test, train}Subject
## files.

my$data <- mutate(my$data, subject =
    as.integer(
        c(
             readLines(my$files[["testSubject"]])
            ,readLines(my$files[["trainSubject"]])
        )
    )
)

## Append new column "activity_class" to "my$data" by repeating 'test' and
## 'train' by the number of observations of each class as derived by the
## respective lengths of the {test, train}Subject files.
## TODO: factor?

my$data <- mutate(
    my$data
    ,activity_class = c(
        rep(
            "test"
            ,length(readLines(my$files[["testSubject"]]))
        )
        ,rep(
            "train"
            ,length(readLines(my$files[["trainSubject"]]))
        )
    )
)

## Requirement 3: Use descriptive activity names for the activity variable.
## The {test, train}Activity files contain the IDs of the actvities
## corresponding to each row of the test and train data sets, respectively. The
## "activityLabels" file contains the labels corresponding to the activity
## IDs within {test, train}Activity.  Joining the rbind of {test, train}Activity 
## with "activityLabels" creates a data frame with observations corresponding to 
## those in the "my$data" data frame with two variables, the activity ID in V1
## and the activity label in V2. Append new column "activity" to "data" with
## column "V2" from the merged data frame.
## TODO: factor?

my$data <- mutate(my$data, activity =
    join(
        rbind(
            read.table(my$files[["testActivity"]])
            ,read.table(my$files[["trainActivity"]])
        )
        ,read.table(my$files[["activityLables"]])
        ,by = "V1"
    )$V2
)

## Requirement 5: Create independent, tidy data set with the average of each
## variable grouped by activity and subject.
## Used the "dplyr" "group_by" function to aggregate the data by subject and
## activity. Apply mean to each un-grouped column via the "dplyr"
## "summarise_each" function.
## TODO: Exclude activity_class from group?

my$summarizedData <- (
    my$data
    %>% group_by(subject, activity, activity_class)
    %>% summarise_each(funs(mean))
)

## Cleanup environment.
#rm(files, envir=my)