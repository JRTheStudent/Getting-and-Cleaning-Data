## The requirements for this script provided within the course are as follows:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each 
##    measurement. 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names. 
## 5. From the data set in step 4, creates a second, independent tidy data set 
##    with the average of each variable for each activity and each subject.

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

## Load libraries for use.  Note "plyr" needs to be loaded before "dplyr"

library(plyr)
library(dplyr)

## Create an environment for this script so other names assigned within do not
##  clobber anything in the runtime Global Environment.

my <- new.env()

## Create a character vector of the files required for processing.

my$files <- c( 
     "features"       = "./data/UCI HAR Dataset/features.txt"
    ,"activityLables" = "./data/UCI HAR Dataset/activity_labels.txt"
    ,"testData"       = "./data/UCI HAR Dataset/test/X_test.txt"
    ,"testActivity"   = "./data/UCI HAR Dataset/test/y_test.txt"
    ,"testSubject"    = "./data/UCI HAR Dataset/test/subject_test.txt"
    ,"trainData"      = "./data/UCI HAR Dataset/train/X_train.txt"
    ,"trainActivity"  = "./data/UCI HAR Dataset/train/y_train.txt"
    ,"trainSubject"   = "./data/UCI HAR Dataset/train/subject_train.txt"
)

## 1. Merges the training and the test sets to create one data set.
## 3. Uses descriptive activity names to name the activities in the data set
## 1a. Read in the {test, train} data
## 1b. Mutate in the {test, train} subjects
## 1c. Mutate in the {test, train} "activity_class".

my$testData <- read.table(my$files[["testData"]]) %>%
    mutate(subject = as.integer(readLines(my$files[["testSubject"]]))) %>%
    mutate(activity_class = rep("test", n()))

my$trainData <- read.table(my$files[["trainData"]]) %>%
    mutate(subject = as.integer(readLines(my$files[["trainSubject"]]))) %>%
    mutate(activity_class = rep("train", n()))

## 1d. Add "activity" by joining "{test,train}Activity" and "activityLabels"
##     This implicitly meets the requirements of requirement 3.

my$testData$activity <- join(
     read.table(my$files[["testActivity"]])
    ,read.table(my$files[["activityLables"]])
    ,by = "V1"
)$V2

my$trainData$activity <- join(
     read.table(my$files[["trainActivity"]])
    ,read.table(my$files[["activityLables"]])
    ,by = "V1"
)$V2

## 1e. Merge the the training and the test sets to create one data set.

my$data <- rbind(my$testData, my$trainData)

## 4. Appropriately labels the data set with descriptive variable names.
## The "features" file contains a numbered list of column names for the  
## {test,train} data sets.  Extract values from column V2 of features.txt and  
## assign to names(data). Doing this before requirement 2 makes that task
## both easier to do and understand.

my$sourceColNames <- as.character(read.table(my$files[["features"]])$V2)
names(my$data)[1:length(my$sourceColNames)] <- my$sourceColNames

## 2. Extracts only the measurements on the mean and standard deviation for each 
##    measurement. 
## Create a character vector of columns to remove by grepping the inverse of the
## columns from "my$sourceColNames" matching a case-insensitive search for "std"
## and "mean".  This preserves any columns that have been added as well as any
## that contain "std" or "mean" (upper or lowercase) anywhere in the column
## name.

my$dropCols <- grep(
     "mean|std"
    ,my$sourceColNames
    ,ignore.case = T
    ,invert = T
    , value = T
)
my$data <- my$data[, ! names(my$data) %in% my$dropCols]


## 5. From the data set in step 4, creates a second, independent tidy data set 
##    with the average of each variable for each activity and each subject.

my$summarizedData <- (
    my$data
    %>% group_by(subject, activity, activity_class)
    %>% summarise_each(funs(mean))
)

## Cleanup environment
## rm(my)