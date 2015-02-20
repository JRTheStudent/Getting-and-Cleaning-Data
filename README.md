# Getting and Cleaning Data: Course project README

## 1: Overview
This repository contains the code required to process the "Human Activity Recognition Using Smartphones Data Set"[1] from the UCI Machine Learning Repository[2], the output of the processing as well as various files describing the data and how to use the code and reproduce the output.

## 2: Repository Contents
1. README.md (this file) - Describes the following:
  * The contents of the repository.
  * How the code works and the steps required to transform the raw data set to     the tidy summarized output.
  * An explanation of how to use the code and data within this repository.
2. run_analysis.R[3] - The code used to transform the raw data set to the tidy    summarized output.
3. summarized_data.txt[4] - The output from run_analysis.R.
4. CodeBook.md[5] - The Code Book/Data Dictionary describing variables in the   output (summarized_data.txt).

## 3: run_analysis.R - Explanation of Data Transformation and Summary
This script creates a function "UCIHARSummarize" that is designed to process the UCI HAR data set per the following requirements provided within the course[6]:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set.
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

The function will write the data meeting requirement 5 to "./summarized_data.txt" and prints a message to the console conveying this information.

The "UCIHARSummarize" function requires no parameters and makes the following non-validated assumptions about the data:
* All files in "files" exist and are readable (see example in "Setup steps.")
* features.txt contains one numbered line corresponding to each variable in X_{test, train}.txt
* X_{test, train}.txt contain the same order and number of variables.
* y_{test, train}.txt contain one line corresponding to each observation in X_{test, train}.txt and each value is classified by a corresponding label in activity_labels.txt
* subject_{test, train}.txt contain one line corresponding to each observation in X_{test, train}.txt

### 3a. Requirement 1: Merge the test and training data sets.
###### Lines 25-44
The X_{test, train}.txt data sets both contain 561 variables with 2,947 and 7,352 observations, respectively.  Wrapping "read.tables" with "rbind" 'stacks' the test data set atop the train data set, creating a data frame with 10,299 observations of 561 variables. Combining the data sets by 'stacking' in one step is more efficient but all subsequent 'stacked' actions _must_ proceed by 'stacking' test data atop train data to maintain coherence.  

After creating and populating the data set with the measurement data, the "subect" column is appended via "rbind" "mutate" wrapping "readLines" of the subject_{test, train}.txt files.

### 3b. Requirement 2: Extract only mean and standard deviation measurements.
###### Lines 46-56
This step sub-selects columns with variable names containing the character strings "mean" and "std" (standard deviation), case-insensitively and in any position within the variable name.  As the course requirements are not explicit and the inclusion of (potentially) superfluous variables does not affect required processing (the variables are independent in the processing required) it is preferable to err on the side of broader inclusivity. 86 measurement variables match this criteria, thus this trims the merged data frame to 87 variables (the 86 matching variables as well as "subject" which was appended above) while still maintaining 10,299 observations.

The features.txt file contains a numbered list of column names corresponding to the test and train data sets.  This file is read into a variable, then "grep" is applied (using the criteria described above) to identify column names that match the critera and preserve them in the variable "oColKeepNames" to assist in the fulfillment of Requirement 4 below.  Finally grep is used again with the same criteria, but this time with the "invert" parameter to identify column numbers that do not match the critera and they are subselected out of "data."

### 3c. Requirement 3: Use descriptive activity names for the activity variable.
###### Lines 58-72
The y_{test, train}.txt files contain the IDs of the actvities corresponding to each row of the test and train data sets, respectively. The activity_labels.txt file contains the labels corresponding to the activity IDs within y_{test, train}.txt.  Joining the rbind of y_{test, train}.txt with "activity_labels.txt" creates a data frame with observations corresponding to those in the "data" data frame with two variables, the activity ID in "V1" and the activity label in "V2". Append the new column "activity" to "data" by mutating in the selection of column "V2" from the joined data frame described above.

### 3d. Requirement 4: Label the data set with descriptive variable names.
###### Lines 74-76
In step 3b the variable "oColKeepNames" was derived and created to persist the descriptive names of the measurement columns in the data set.  Requirement 4 is fulfilled by assigning this character vector to the corresponding indices in the "data" data set.  

### 3e. Requirement 5: Create independent, tidy data set with the average of each variable grouped by activity and subject.
###### Lines 78-95
Per the course definition[7], the components of tidy data are as follows:
1. Each Variable in one column
2. Each different observation of that variable should be in a different row
3. There should be one table for each "kind" of variable
4. If you have multiple tables, they should include a column in the table that allows them to be linked.

The output produced by step 5 is a data frame consisting of 180 observations of 88 variables.  The tidiness of the output matching the criteria established above can be demonstrated as follows:  

1.86 measurement variables met the acceptance criteria (established in 3b), thus with the inclusion of the two identifying columns ("subject" and "activity"), the summarized data set maintains 88 variables.

```
> ncol(sData)
[1] 88
```

2. The raw data set contained measurement data taken from 30 subjects each performing six activities.  Because requirement 5 calls for an aggregation by subject and activity, this produces 180 observations (30 * 6).

```
> nrow(sData)
[1] 180
```

3. Each observation of the summarized data consists of a discrete and logical set of variables of the same "kind".
4. Does not apply as the output consists of one table.

Per the course requirements [6], the variable names of the data are descriptive both in the working and summarized data sets ("data" and "sData", respectively). In both cases the appended columns ("subject"" and "activity") are labeled as such, and the descriptive activity names have been added to the "activity" variable as defined in "activity_labels.txt."  In the working data set "data" the measurement variables (columns 1-86) are named with the labels identified within "activities.txt."  In the summarized data set "sData" the measurement colums are averaged by groupings o activity and subject, thus the prefix "mean_" is prepended to the associated measurement name.  For details about the summarized data see the Code Book[5].

Requirement 5 is met by using the "dplyr" "group_by" function to aggregate the data by activity and subject. Apply mean to each un-grouped column via the "dplyr" "summarise_each" function. This produces a data frame with 180 observations (30 subjects each performing 6 activities) by 88 variables (subject, activity and the means of the 86 measurement variables grouped by subject and activity).

## 4: How to Use the Code and Data Within this Repository and Reproduce the Results.

An example of the R command to download the code from this repository:

```
download.file("https://raw.githubusercontent.com/JRTheStudent/Getting-and-Cleaning-Data/master/run_analysis.R", destfile="./run_analysis.R")
```

An example of the R command to download the original, summarized output from the code in this repository:

```
download.file("https://raw.githubusercontent.com/JRTheStudent/Getting-and-Cleaning-Data/master/summarized_data.txt", destfile = "./summarized_data.txt")
```

Example R commands to download and uncompress the original source data:

```
if(!(file.exists("./data") & file.info("./data")$isdir)) dir.create("./data")
download.file(
    paste(
         "https://d396qusza40orc.cloudfront.net/"
        ,"getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        ,sep = ""
    )
    ,destfile = "./data/data.zip"
)
write(date(), file = "./data/date_downloaded.txt")
unzip("./data/data.zip", exdir = "./data")
```
An example of the execution of the code in this repository (requires both the run_analysis.R script and the UCI HAR data downloaded and uncompressed as described above):

```
> source('./run_analysis.R')
> UCIHARSummarize()
Summarized data has been written to: ./summarized_data.txt
```

## 6: Citations
1. https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
2. http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
3. https://github.com/JRTheStudent/Getting-and-Cleaning-Data/blob/master/run_analysis.R
4. https://github.com/JRTheStudent/Getting-and-Cleaning-Data/blob/master/summarized_data.txt
5. https://github.com/JRTheStudent/Getting-and-Cleaning-Data/blob/master/CodeBook.md
6. https://class.coursera.org/getdata-011/human_grading/view/courses/973498/assessments/3/submissions
7. https://d396qusza40orc.cloudfront.net/getdata/lecture_slides/01_03_componentsOfTidyData.pdf