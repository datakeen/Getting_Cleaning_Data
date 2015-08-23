
 ## You should create one R script called run_analysis.R that does the following. 
  
 ##  1. Merges the training and the test sets to create one data set.
 ##  2. Extracts only the measurements on the mean and standard deviation for each measurement. 
 ##  3. Uses descriptive activity names to name the activities in the data set
 ##  4. Appropriately labels the data set with descriptive variable names. 
 ##  5. From the data in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


#1. merge the training and test data sets to create one data set
# this assumes the working directory is set correctly to find the training and testing sets
# training set
# 'UCI HAR Dataset/train/X_train.txt': Training set
trainData <- read.table("./UCI HAR Dataset/train/x_train.txt")
# get the subject and activity values
trainSub <- read.table("./UCI HAR Dataset/train/subject_train.txt")
trainAct <- read.table("./UCI HAR Dataset/train/y_train.txt")
# add the subject and activity values to the dataset
trainDataAll <- cbind(trainSub,trainAct,trainData)

# test sets
# 'UCI HAR Dataset/test/X_test.txt': Test set.
testData <- read.table("./UCI HAR Dataset/test/x_test.txt")
# get the subject and activity values
testSub <- read.table("./UCI HAR Dataset/test/subject_test.txt")
testAct <- read.table("./UCI HAR Dataset/test/y_test.txt")
# add the subject and activity values to the dataset
testDataAll <- cbind(testSub,testAct,testData)

# Step 1. merge the two data sets
## use rbind to add the test data to the train data
mergedData <- rbind(trainDataAll,testDataAll)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# do this by looking the labels data to determine which columns contain mean or standard deviation
# read the table containg the labels into a data frame 
labelSet <- read.table("./UCI HAR Dataset/features.txt")
# the labels are in the second column of the data frame
labels <- labelSet[,2]
# convert the labels to characters
# newlabels <- as.character(labels)
labelsChar <- as.character(labels)
# create a new vector of labels which will be used for the data. The label set will include the columns for Subject and Activity
newlabels <- c('Subject','Activity',labelsChar)

# search the labels for only get only the columns for mean and standard deviation
# utilize the 'grep' function to perform the search
colsMean <- grep("mean", newlabels, ignore.case=TRUE)
colsStd <- grep("std", newlabels, ignore.case=TRUE)
# add the two column vectors together
colsAll <- c(colsMean,colsStd)
# sort the column values
colsFinal <- sort(colsAll)

#now create a new data frame of just the mean and standard deviation columns
# to go along with the subject (column 1) and activity (column 2) values
mergedSubset <- mergedData[c(1,2,colsFinal)]

##  3. Uses descriptive activity names to name the activities in the data set
# the descriptive names are contained in 'activity_labels.txt' file
# from this file the activities:
# 1 WALKING
# 2 WALKING_UPSTAIRS
# 3 WALKING_DOWNSTAIRS
# 4 SITTING
# 5 STANDING
# 6 LAYING
# so use this with the gsub function to replace the activity values with the descriptive names
mergedSubset[,2] <- gsub("1","walking",mergedSubset[,2])
mergedSubset[,2] <- gsub("2","walking_upstairs",mergedSubset[,2])
mergedSubset[,2] <- gsub("3","walking_downstairs",mergedSubset[,2])
mergedSubset[,2] <- gsub("4","sitting",mergedSubset[,2])
mergedSubset[,2] <- gsub("5","standing",mergedSubset[,2])
mergedSubset[,2] <- gsub("6","laying",mergedSubset[,2])

##  4. Appropriately labels the data set with descriptive variable names. 
# will need to just use the subset of lables which correspond to the data subset of just means and standard deviations
finalLabels <- newlabels[c(1,2,colsFinal)]
colnames(mergedSubset) <- finalLabels

##  5. From the data in step 4, creates a second, independent tidy data set with the average of each variable
##     for each activity and each subject.
# perform this by using the functions included with the 'dplyr' library
# will need to install the 'dplyr' library then load it
library(dplyr)
# now take the mergedSubset data frame and group it by Subject and Activity and then summarise each other column it's mean
# save this to a new data frame called 'TidySet'
TidySet <- mergedSubset %>% group_by(Subject,Activity) %>% summarise_each(funs(mean))
# now save the TidySet data frame to a text file which will be stored in github.
write.table(TidySet,file="Q5_Tidy_Data_Set.txt",row.name=FALSE)

