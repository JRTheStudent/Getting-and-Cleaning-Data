## The course instructions provided for this script are as follows:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each 
##    measurement. 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names. 
## 5. From the data set in step 4, creates a second, independent tidy data set 
##    with the average of each variable for each activity and each subject.

## Non-validated assumptions about data:
## -All files in "files" exist and are readible (see example in "Setup steps.")
## -features.txt contains one numbered line corresponding to each variable
##    in X_{test,train}.txt
## -X_{test,train}.txt contain the same order and number of variables. 
## -y_{test,train}.txt contain one line corresponding to each observation
##    in X_{test,train}.txt and each value is classified by a corresponding 
##    label in activity_labels.txt
## -subject_{test,train}.txt contain one line corresponding to each observation
##    in X_{test,train}.txt

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

library(plyr)
library(dplyr)

files <- c( 
     "features"         = "./data/UCI HAR Dataset/features.txt"
    ,"activity_lables" = "./data/UCI HAR Dataset/activity_labels.txt"
    ,"test_data"       = "./data/UCI HAR Dataset/test/X_test.txt"
    ,"test_activity"   = "./data/UCI HAR Dataset/test/y_test.txt"
    ,"test_subject"    = "./data/UCI HAR Dataset/test/subject_test.txt"
    ,"train_data"      = "./data/UCI HAR Dataset/train/X_train.txt"
    ,"train_activity"  = "./data/UCI HAR Dataset/train/y_train.txt"
    ,"train_subject"   = "./data/UCI HAR Dataset/train/subject_train.txt"
)

## 1. Merges the training and the test sets to create one data set.
## 1a. Read in the data
## 1b. Mutate in the subjects
## 1c. Mutate in the "activity_class" {test,train}

test_data <- read.table(files[["test_data"]]) %>%
    mutate(subject = as.integer(readLines(files[["test_subject"]]))) %>%
    mutate(activity_class = rep("test", n()))

train_data <- read.table(files[["train_data"]]) %>%
    mutate(subject = as.integer(readLines(files[["train_subject"]]))) %>%
    mutate(activity_class = rep("train", n()))

## 1d. Add "activity" by joining "{test,train}_activity" and "activity_labels"

test_data$activity <- join(
     read.table(files[["test_activity"]])
    ,read.table(files[["activity_lables"]])
    ,by = "V1"
)$V2

train_data$activity <- join(
     read.table(files[["train_activity"]])
    ,read.table(files[["activity_lables"]])
    ,by = "V1"
)$V2

## 1e. Merge the the training and the test sets to create one data set.
data <- rbind(test_data, train_data)

## 2. Extracts only the measurements on the mean and standard deviation for each 
##    measurement. 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names
## 5. From the data set in step 4, creates a second, independent tidy data set 
##    with the average of each variable for each activity and each subject.
