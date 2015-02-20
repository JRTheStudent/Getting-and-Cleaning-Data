## For detailed information about this script, see the README.md within the 
## repository at https://github.com/JRTheStudent/Getting-and-Cleaning-Data/

UCIHARSummarize <- function(){

    ## Load libraries for use.  Note "plyr" needs to be loaded before "dplyr."
    
    library(plyr)
    library(dplyr)
    
    ## Create a character vector of the files required for processing.
    
    files <- c(
        "features"        = "./data/UCI HAR Dataset/features.txt"
        ,"activityLables" = "./data/UCI HAR Dataset/activity_labels.txt"
        ,"testData"       = "./data/UCI HAR Dataset/test/X_test.txt"
        ,"testActivity"   = "./data/UCI HAR Dataset/test/y_test.txt"
        ,"testSubject"    = "./data/UCI HAR Dataset/test/subject_test.txt"
        ,"trainData"      = "./data/UCI HAR Dataset/train/X_train.txt"
        ,"trainActivity"  = "./data/UCI HAR Dataset/train/y_train.txt"
        ,"trainSubject"   = "./data/UCI HAR Dataset/train/subject_train.txt"
        ,"sDataOutput"       = "./summarized_data.txt"
    )
    
    ## Requirement 1: Merge the test and training data sets.  

    ## Populate the data frame with the test and train data sets via rbind. 
    
    data <- rbind(
        read.table(files[["testData"]])
        ,read.table(files[["trainData"]])
    )
    
    ## Append "subject" column.
    
    data <- mutate(
        data
        ,subject = as.integer(
            c(
                readLines(files[["testSubject"]])
                ,readLines(files[["trainSubject"]])
            )
        )
    )

    ## Requirement 2: Extract only mean and standard deviation measurements.
    
    ## Identify columns names via "grep" to keep (for requirement 4) and column
    ## numbers to drop and subselect out for requirement 2.
    
    oColNames     <- read.table(files[["features"]])$V2
    oColRegExp    <- "mean|std"
    oColKeepNums  <- grep(oColRegExp, oColNames, ignore.case = T)
    oColKeepNames <- as.character(oColNames[oColKeepNums])
    oColDropNums  <- grep(oColRegExp, oColNames, ignore.case = T, invert = T)
    data          <- data[-oColDropNums]
   
    ## Requirement 3: Use descriptive activity names for the activity variable.
    
    ## Mutate in "activity" column by joining "activityLabels" with rbind of 
    ## {test, train}Activity files.
    
    activities <- join(
        rbind(
            read.table(files[["testActivity"]])
            ,read.table(files[["trainActivity"]])
        )
        ,read.table(files[["activityLables"]])
        ,by = "V1"
    )$V2
    
    data <- mutate(data, activity = activities)
    
    ## Requirement 4: Label the data set with descriptive variable names.
   
    names(data)[1:length(oColKeepNames)] <- oColKeepNames

    ## Requirement 5: Create independent, tidy data set with the average of each
    ## variable grouped by activity and subject.
    
    sData <- (
        data
        %>% group_by(activity, subject)
        %>% summarise_each(funs(mean))
    )
    
    ## Prefix all measurement variables with "mean_".
    
    for (i in grep("activity|subject", names(sData), invert = T)){
        names(sData)[i] <- paste("mean_" ,names(sData)[i], sep = "")    
    }
    
    ## Write "sData" to a file.
    
    write.table(sData, files[["sDataOutput"]], row.names = F)
    
    message(
        paste("Summarized data has been written to:" , files[["sDataOutput"]])
    )
       
}