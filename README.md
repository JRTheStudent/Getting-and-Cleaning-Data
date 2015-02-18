# Getting and Cleaning Data: Course project

## 1: Overview
This repository contains the code required to process the "Human Activity Recognition Using Smartphones Data Set"[1] from the UCI Machine Learning 
Repository[2], the output of the processing as well as various files describing
the data and how to use the code.

## 2: Repository Contents
1. README.md (this file) - Describes the following:
  * The contents of the repository.
  * How the code works and the steps required to transform the raw data set to
    the tidy summarized output.
  * An explanation of how to use the code and data within this repository.
  * An explanation of how to reproduce the output.
2. run_analysis.R[3] - The code used to transform the raw data set to the tidy
   summarized output.
3. summarized_data.txt[4] - The output from run_analysis.R
4. CodeBook.md[5] - The Code Book/Data Dictionary describing variables in the 
   output (summarized_data.txt)

## 3: run_analysis.R - Explanation of Data Transformation and Summary
This script is intended to be executed by the R "source" command - it does not
encapsulate processing within a function.   The requirements for this script provided within the course[6] are as follows:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each
measurement.
3. Uses descriptive activity names to name the activities in the data set.
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set
with the average of each variable for each activity and each subject.

To fulfill these requirements in the most efficient way the run_analysis.R 
script meets requirement 4 after requirement 1.  Thus the general structure of 
the script is to address the requirements in the order 1, 4, 2, 3, 5 (as 
described above).

This script creates an environment named "my" which contains three variables:
* files: A character vector consisting of the files used in processing and 
output.
* data: The data frame constructed to satisfy requirements 1-4.
* summarizedData: The data frame constructed to satisfy requirement 5.

This script also outputs the "summarizedData" both to the file 
"summarized_data.txt" in the working directory as well as to the console.

The script makes the following non-validated assumptions about the data:
* All files in "files" exist and are readable (see example in "Setup steps.")
* features.txt contains one numbered line corresponding to each variable
in X_{test, train}.txt
* X_{test, train}.txt contain the same order and number of variables.
* y_{test, train}.txt contain one line corresponding to each observation
in X_{test, train}.txt and each value is classified by a corresponding
label in activity_labels.txt
* subject_{test, train}.txt contain one line corresponding to each observation
in X_{test, train}.txt

### 3a. Requirement 1: Merge the test and training data sets.
###### Lines 68-80
The {test, train}Data data sets both contain 561 variables with 2,947 and
7,352 observations, respectively.  Wrapping "read.tables" with "rbind"
'stacks' the test data set atop the train data set, creating a data frame
with 10,299 observations of 561 variables. Combining the data sets by
'stacking' in one step is more efficient but all subsequent 'stacked'
actions _must_ proceed by 'stacking' test data atop train data to maintain
coherence.

### 3b. Requirement 4: Label the data set with descriptive variable names.
###### Lines 82-87
The "features" files contains a numbered list of column names for the test
and train data sets.  Extract values from column "V2" of "features" and
assign to "names(my$data)."

### 3c. Requirement 2: Extract only mean and standard deviation measurements.
###### Lines 89-97
Subselect columns with variable names containing the character strings
"mean" and "std" (standard deviation), case-insensitively and in any position
within the variable name.  As the requirements are not explicit and the
inclusion of (potentially) superfluous variables does not affect required
processing (the variables are independent in the processing required) it is preferable to err on the side of broader inclusivity.

### 3d. Append columns "subject" and "activity class" to the merged data set.
###### Lines 99-128
Deferring the appending of new columns to the data set until after meeting requirements 4 and 2 (detailed in 3b and 3c above) makes those steps both simpler to perform and more flexible in the code- any subsequent columns can be safely added after the origin data is labeled and extraneous columns are dropped. 

The column "subject" is appended to "my$data" by rbind on the {test, train}Subjectfiles.  Column "activity_class" is appended to "my$data" by repeating 'test' and
'train' by the number of observations of each class as derived by the
respective lengths of the {test, train}Subject files.

### 3e. Requirement 3: Use descriptive activity names for the activity variable.
###### Lines 130-150
The {test, train}Activity files contain the IDs of the actvities
corresponding to each row of the test and train data sets, respectively. The
"activityLabels" file contains the labels corresponding to the activity
IDs within {test, train}Activity.  Joining the rbind of {test, train}Activity 
with "activityLabels" creates a data frame with observations corresponding to 
those in the "my$data" data frame with two variables, the activity ID in V1
and the activity label in V2. Append new column "activity" to "data" with
column "V2" from the merged data frame.

### 3f. Requirement 5: Create independent, tidy data set with the average of each variable grouped by activity and subject.
###### Lines 152-163
Use the "dplyr" "group_by" function to aggregate the data by subject and
activity. Apply mean to each un-grouped column via the "dplyr"
"summarise_each" function.

## 4: how to use the code and data within this repository.

## 5: Reproduce Output

## N: Citations
1. https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
2. http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
3. https://github.com/JRTheStudent/Getting-and-Cleaning-Data/blob/master/run_analysis.R
4. https://github.com/JRTheStudent/Getting-and-Cleaning-Data/blob/master/summarized_data.txt
5. https://github.com/JRTheStudent/Getting-and-Cleaning-Data/blob/master/CodeBook.md
6. https://class.coursera.org/getdata-011/human_grading/view/courses/973498/assessments/3/submissions