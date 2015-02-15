## Non-validated assumptions about data:
## -All files in "files" exist and are readible
## -features.txt contains one numbered line corresponding to each variable
##    in X_{test,train}.txt
## -X_{test,train}.txt contain the same order and number of variables. 
## -y_{test,train}.txt contain one line corresponding to each observation
##    in X_{test,train}.txt and each value is classified by a corresponding 
##    label in activity_labels.txt
## -subject_{test,train}.txt contain one line corresponding to each observation
##    in X_{test,train}.txt

library(dplyr)

## if(!(file.exists("./data") & file.info("./data")$isdir)) dir.create("./data")
## download.file(
##     paste( "https://d396qusza40orc.cloudfront.net/"
##           ,"getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
##           ,sep = ""
##     )
##     ,destfile = "./data/data.zip"
## )
## write(date(), file = "./data/date_downloaded.txt")
## unzip("./data/data.zip", exdir = "./data")

## Date downloaded: 2015-02-14 06:53:52 MST

files <- c( "features"        = "./data/UCI HAR Dataset/features.txt"
           ,"activity_lables" = "./data/UCI HAR Dataset/activity_labels.txt"
           ,"test_data"       = "./data/UCI HAR Dataset/test/X_test.txt"
           ,"test_activity"   = "./data/UCI HAR Dataset/test/y_test.txt"
           ,"test_subject"    = "./data/UCI HAR Dataset/test/subject_test.txt"
           ,"train_data"      = "./data/UCI HAR Dataset/train/X_train.txt"
           ,"train_activity"  = "./data/UCI HAR Dataset/train/y_train.txt"
           ,"train_subject"   = "./data/UCI HAR Dataset/train/subject_train.txt"
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
## are appended.  Used in the duplicate column renaming and the "measurements"
## extract below.

nVar <- ncol(data)

## "features" contains a numbered list of column names for the test and train 
## data sets.  Extract values from column V2 of features.txt and assign to 
## names(data).

names(data) <- read.table(files[["features"]])$V2

## The data contain duplicate column names which is incompatible with the dplyr
## summarize function.  The simple fix is to use "make.names" e.g.:
## names(data) <- make.names(names(data), unique=TRUE)
## but this changes column names in undersirable ways.  The following block
## looks for duplicate column names and appends ".N" where "N" starts with
## 2 and increments accordingly.
## Example: fBodyAcc-bandsEnergy()-1,16, fBodyAcc-bandsEnergy()-1,16.2, etc.

col_count <- list()
for (i in 1:nVar){
    ifelse( 
        is.numeric(col_count[[names(data)[i]]])
        ,{    
              col_count[[names(data)[i]]] <- col_count[[names(data)[i]]] + 1
              names(data)[i] <- paste( 
                                    names(data)[i]
                                    ,"."
                                    ,col_count[[names(data)[i]]]
                                    ,sep = ""
                                )
         }
        ,col_count[[names(data)[i]]] <- 1
    )        
}

## Append new column "activity_class" to "data" by repeating 'test' and 'train' 
## by the number of observations of each class as derived by the respective 
## lengths of the {test, train}_subject files.

data$activity_class <- factor(
                           c( rep( "test"
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

data$activity  <- factor(
                      merge( rbind( read.table(files[["test_activity"]])
                            ,read.table(files[["train_activity"]]))
                            ,read.table(files[["activity_lables"]])
                      )$V2
                  )

## Extract the mean and standard deviation for each measurement and preserve
## in "measurements".

measurements <- data.frame( "mean" = sapply(data[,1:nVar], mean, na.rm = T)
                           ,"std_dev" = sapply(data[,1:nVar], sd, na.rm = T)
                )

## create a second, independent tidy data set with the average of each variable
## for each activity and each subject.

## Average each variable summarized by activity and subject.
# names(data) <- make.names(names(data), unique=TRUE)
# g <- group_by(data, subject, activity)
# summarize(g, mean(tBodyAcc.mean...X, na.rm = T))

summarized_data <- (    data 
                    %>% group_by(subject, activity, activity_class)
                    %>% summarise_each(funs(mean))
                   )

## Cleanup processing variables
rm(files, nVar, col_count, i)
