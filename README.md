README.txt

This file describes to code used to produce the results for each step required for this project.  
This code is contained in the run_alalysis.R script.

The requirements to create an R script with does the following:  
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


The Requirements:

1. merge the training and test data sets to create one data set
ASSUMPTION: assumes the working directory is set correctly to find the training and testing sets

	APPROACH:  
	# read the training data into a varialble
	# read the training subject data into a variable
	# read the training activity data into a variable
	# combine the subject, activity, and data information into a single dataframe using the cbind function	
	# read the test data into a varialble
	# read the test subject data into a variable
	# read the test activity data into a variable
	# combine the subject, activity, and data information into a single dataframe using the cbind function	
	# merge the test and training data sets into a new dataframe using the rbind function

	CODE:
	# read the training data set into a dataframe
	trainData <- read.table("./UCI HAR Dataset/train/x_train.txt")

	# read the training data subject and activity values into separate dataframes
	trainSub <- read.table("./UCI HAR Dataset/train/subject_train.txt")
	trainAct <- read.table("./UCI HAR Dataset/train/y_train.txt")

	# add the training subject and activity values to the training data dataframe using cbind
	trainDataAll <- cbind(trainSub,trainAct,trainData)

	# read the test data set into a dataframe
	testData <- read.table("./UCI HAR Dataset/test/x_test.txt")

	# read the test data subject and activity values into separate dataframes
	testSub <- read.table("./UCI HAR Dataset/test/subject_test.txt")
	testAct <- read.table("./UCI HAR Dataset/test/y_test.txt")

	# add the test subject and activity values to the test data dataframe using cbind
	testDataAll <- cbind(testSub,testAct,testData)

	# merge the training and test data sets into a new dataframe (mergedData) using the rbind function
	mergedData <- rbind(trainDataAll,testDataAll)

2. Extracts only the measurements on the mean and standard deviation for each measurement. 

	APPROACH:
	# read the labels (from the 'features.txt' file) into a dataframe
	# search the dataframe to see which columns contain 'mean' or 'std' (for standard deviation)
	# identify the columns (by column number) which contain these values (do this using the 'grep' function)
	# extract a subset of the merged data based on the columns identified above 

	CODE:
	# first read the table containg the labels into a data frame 
	labelSet <- read.table("./UCI HAR Dataset/features.txt")

	# set a vector equal to the second column of the 'labelSet' dataframe (labels are in the second column) 
	labels <- labelSet[,2]

	# convert the labels to characters
	labelsChar <- as.character(labels)

	# our merged dataframe contains values for 'Subject' and 'Activity' in columns 1 and 2, so we have to adjust for that in our lables set
	# create a new vector of labels which will be used for the data. The label set will include the columns for Subject and Activity
	newlabels <- c('Subject','Activity',labelsChar)

	# now search the labels for only the values containing 'mean' and 'std'
	# utilize the 'grep' function to perform the search (utilize ignore.case=TRUE to account for different cases)
	colsMean <- grep("mean", newlabels, ignore.case=TRUE)
	colsStd <- grep("std", newlabels, ignore.case=TRUE)

	# add the two column vectors together
	colsAll <- c(colsMean,colsStd)

	# sort the column values to put in order
	colsFinal <- sort(colsAll)

	# now create a new dataframe of just the mean and standard deviation columns (plus the 'Subject' and 'Activity' columns)
	mergedSubset <- mergedData[c(1,2,colsFinal)]


3. Uses descriptive activity names to name the activities in the data set

	APPROACH:

	# replace the Activity values (in Column 2) with the descriptive names found in the 'activity_labels.txt' file provided with the course
	# The descriptive names to go with the values are as follows: 
		# 1 WALKING
		# 2 WALKING_UPSTAIRS
		# 3 WALKING_DOWNSTAIRS
		# 4 SITTING
		# 5 STANDING
		# 6 LAYING
	# Use the 'gsub' function to replace the activity values with the descriptive names

	CODE:

	# Use the gsub function to replace the activity values with the descriptive names
	# the Activity values are in column 2 of the mergedSubset dataframe
	mergedSubset[,2] <- gsub("1","walking",mergedSubset[,2])
	mergedSubset[,2] <- gsub("2","walking_upstairs",mergedSubset[,2])
	mergedSubset[,2] <- gsub("3","walking_downstairs",mergedSubset[,2])
	mergedSubset[,2] <- gsub("4","sitting",mergedSubset[,2])
	mergedSubset[,2] <- gsub("5","standing",mergedSubset[,2])
	mergedSubset[,2] <- gsub("6","laying",mergedSubset[,2])

4. Appropriately labels the data set with descriptive variable names. 

	APPROACH:
	# use the 'colnames' function to label the columns in the 'mergedSubset' dataframe
	# we first get the labels values from the 'newlabels' vector set in Step 2 
	# that are just for 'mean' or 'std' (use the 'colsFinal' vector set in Step 2) and set to the 'finalLabels' vector
	# then set the 'mergedSubset' column values to the values in 'finalLables'
	
	CODE:
	# get the labels just for 'Subject', 'Activity' and those related to 'mean' or 'std'
	finalLabels <- newlabels[c(1,2,colsFinal)]

	# set the column labels of the merged dataframe to the descriptive values
	colnames(mergedSubset) <- finalLabels

5. From the data in step 4, creates a second, independent tidy data set with the average of each variable

	APPROACH:
	# utilize the functions included with the 'dplyr' library to reduce the data to a tidy data set
	# will need to install the 'dplyr' library then load it
	# first use the 'group_by' function to group the mergedSubset dataframe 'Subject' and 'Activity'
	# next send that result to the 'summarise_each' function to determine the mean for each data value (column)
	# set the result to a new dataframe called 'TidySet'
	# write the TidySet dataframe to a text file using the write.text function

	CODE:
	# utilize the functions included with the 'dplyr' library to reduce the data to a tidy data set
	# will need to install the 'dplyr' library then load it
	library(dplyr)

	# now take the mergedSubset data frame and group it by 'Subject' and 'Activity' and then summarise each other column it's mean
	# save this to a new data frame called 'TidySet'
	TidySet <- mergedSubset %>% group_by(Subject,Activity) %>% summarise_each(funs(mean))

	# now save the TidySet data frame to a text file which will be stored in github.
	write.table(TidySet,file="Q5_Tidy_Data_Set.txt",row.name=FALSE)

