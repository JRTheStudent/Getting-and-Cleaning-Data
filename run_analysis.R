## Source Data: https://d396qusza40orc.cloudfront.net/
##              getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
## Download time: 2015-02-14 06:53:52 MST
 
files <- c( "features"        = "./data/features.txt"
           ,"activity_lables" = "./data/activity_labels.txt"
           ,"test_data"       = "./data/test/X_test.txt"
           ,"test_activity"   = "./data/test/y_test.txt"
           ,"test_subject"    = "./data/test/subject_test.txt"
           ,"train_data"      = "./data/train/X_train.txt"
           ,"train_activity"  = "./data/train/y_train.txt"
           ,"train_subject"   = "./data/train/subject_train.txt"
          )

## The {test,train}_data data sets both contain 561 variables with 2,947 and 
## 7,352 observations, respectively.  Wrapping the read.tables with rbind 
## 'stacks' the test data set atop the train data set, creating a data frame 
## with 10,299 observations of 561 variables. The fill argument to read.table 
## creates NA's for missing values. Combining the data sets by 'stacking' in one 
## step is more efficient, but all subsequent 'stacked' actions _must_ proceed 
## by 'stacking' test data atop train data to maintain coherence.

data <- rbind( read.table(files[["test_data"]], fill = T)
              ,read.table(files[["train_data"]], fill = T)
             )

## Capture the number of variables in the data set before additional data 
## are appended.

nVar <- ncol(data)

## features contains a numbered list of column names for the test and train 
## data sets.  Extract values from column V2 of features.txt and assign to 
## names(data).

names(data) <- read.table(files[["features"]])$V2

## Append new column "activity_class" to "data" by repeating 'test' and 'train' 
## by the number of observations of each class as derived by the respective 
## lengths of the {test, train}_subject files.

data$activity_class <- factor(c( rep( "test"
                                     ,length(readLines(files[["test_subject"]]))
                                    )
                                ,rep( "train"
                                     ,length(readLines(files[["train_subject"]]))
                                    )
                               )
                             )

## Append new column "subject" to "data" by rbind on the {test_train}_subject
## files.

data$subject <- as.integer(c( readLines(files[["test_subject"]])
                             ,readLines(files[["train_subject"]])
                            )
                          )

## The {test,train}_activity files contain the IDs of the actvities 
## corresponding to each row of the test and train data sets, respectively. The 
## activity_labels file contains the labels corresponding to the activity
## IDs within {test,train}_activity.  Merging the rbind of {test,train}_activity 
## with activity_labels creates a data frame with observations corresponding to 
## those in the "data" data frame with two variables, the activity ID in V1 and 
## the activity label in V2. Append new column "activity" to "data" with column
## "V2" from the merged data frame.

data$activity  <- factor(merge( rbind( read.table(files[["test_activity"]])
                                      ,read.table(files[["train_activity"]]))
                               ,read.table(files[["activity_lables"]])
                              )$V2
                        )

## Extract the mean and standard deviation for each measurement and preserve
## in 

measurements <- data.frame( "mean" = sapply(data[,1:nVar], mean, na.rm = T)
                           ,"std_dev" = sapply(data[,1:nVar], sd, na.rm = T)
                          )

## Average each variable summarized by activity and subject. 