## Getting and Cleaning Data: Course Project R Script

## This script performs the following steps:
##      1. Merges the training and the test sets to create one data set.
##      2. Extracts only the measurements on the mean and standard deviation for each measurement.
##      3. Uses descriptive activity names to name the activities in the data set
##      4. Appropriately labels the data set with descriptive variable names.
##      5. From the data set in step 4, creates a second, independent tidy data set with the average 
##         of each variable for each activity and each subject.

## Load libraries
library(tidyr)
library(plyr)
library(dplyr)
library(reshape2)


## Download files
if(!dir.exists("./UCI HAR Dataset")){
        if(!file.exists("UCI HAR Dataset.zip")){
               fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
               download.file(fileUrl, "UCI HAR Dataset.zip")
        }
        unzip("UCI HAR Dataset.zip")
}

## Read data and rename variables to make them easier to work with
## (X_train and X_test variable names come from the features.txt file)
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
y_test <- y_test %>% dplyr::rename(activityId = V1)

y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
y_train <- y_train %>% dplyr::rename(activityId = V1)

subjects_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
subjects_test <- subjects_test %>% dplyr::rename(subjectId = V1)
subjects_test$subjectId <- as.factor(subjects_test$subjectId) # convert to factor

subjects_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
subjects_train <- subjects_train %>% dplyr::rename(subjectId = V1)
subjects_train$subjectId <- as.factor(subjects_train$subjectId) # convert to factor

features <- read.table("./UCI HAR Dataset/features.txt")
features <- features %>% dplyr::rename(featureId = V1, featureCode = V2)

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
activity_labels <- activity_labels %>% dplyr::rename(activityId = V1, activityCode = V2)

X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
names(X_test) <- features$featureCode # assign descriptive names from feature.txt

X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
names(X_train) <- features$featureCode # assign descriptive names from feature.txt


## Merge the training and the test sets to create one data set. Also assign label to activity.
Test_data <- cbind(y_test, subjects_test, X_test)
Train_data <- cbind(y_train, subjects_train, X_train)

Complete_Data <- rbind(Test_data, Train_data)

Complete_Data <- merge(activity_labels, Complete_Data) # get descriptive activity names from activity_labels.txt


## Extract only the measurements on the mean and standard deviation for each measurement. Remove activity Id.
columns_to_extract <- grepl("mean\\(\\)|std\\(\\)", names(Complete_Data))
columns_to_extract[2:3] <- TRUE #force activityCode and subjectId to be extracted

meanAndStd_Data <- Complete_Data[,columns_to_extract]

## From the data set in step 4, create a second, independent tidy data set with the average 
## of each variable for each activity and each subject.
Tidy_Data <- meanAndStd_Data %>% 
                group_by(subjectId, activityCode) %>%
                summarise_all(list(mean))

## Export tidy dataset
write.csv(Tidy_Data, "Tidy_Data.csv")







