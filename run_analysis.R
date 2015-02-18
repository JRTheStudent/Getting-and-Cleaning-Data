## For detailed information about this script, see the README.md within the 
## repository at https://github.com/JRTheStudent/Getting-and-Cleaning-Data/
## 
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
    ,"sdOutput"       = "./summarized_data.txt"
)

## Requirement 1: Merge the test and training data sets.

my$data <- rbind(
    read.table(my$files[["testData"]])
    ,read.table(my$files[["trainData"]])
)

## Requirement 4: Label the data set with descriptive variable names.

names(my$data) <- as.character(read.table(my$files[["features"]])$V2)

## Requirement 2: Extract only mean and standard deviation measurements.

my$data <- my$data[, grep("mean|std", names(my$data), ignore.case = T)]

## Append new column "subject" to "my$data" by rbind on the {test, train}Subject
## files.

my$data <- mutate(my$data, subject =
                      as.integer(
                          c(
                              readLines(my$files[["testSubject"]])
                              ,readLines(my$files[["trainSubject"]])
                          )
                      )
)

## Append new column "activity_class" to "my$data."

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
## TODO: Exclude activity_class from group?

my$summarizedData <- (
    my$data
    %>% group_by(subject, activity, activity_class)
    %>% summarise_each(funs(mean))
)

## Write "summarizedData" to a file
write.table(my$summarizedData, my$files[["sdOutput"]], row.names = F)

## Output "summarizedData"
print(my$summarizedData)