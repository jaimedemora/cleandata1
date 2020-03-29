##########################################################################################################

## Coursera Getting and Cleaning Data Course Project
## Jaime de Mora
## 03/26/2020

# runAnalysis.r File Description:

# This script will perform the following steps on the UCI HAR Dataset downloaded from 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

##########################################################################################################
library(reshape2)
file_name <- "getdata_dataset.zip"

if(!file.exists(file_name)){
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl, file_name, method=curl)
  }


#reading training Data

features <- read.table("UCI HAR Dataset/features.txt", header=FALSE)
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", header=FALSE)
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header=FALSE)
x_train <- read.table("UCI HAR Dataset/train/x_train.txt", header=FALSE)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", header=FALSE)


colnames(activity_labels) = c("activityId", "activityType")
colnames(subject_train) = ("subjectId")
colnames(x_train) = features[,2]
colnames(y_train) = ("activityId")

trainingData <- cbind(y_train, subject_train, x_train)

#reading test data

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header=FALSE)
x_test <- read.table("UCI HAR Dataset/test/x_test.txt", header=FALSE)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", header=FALSE)

colnames(subject_test) = "subjectId"
colnames(y_test) = "activityId"
colnames(x_test) = features[,2]

testData <- cbind(y_test, subject_test, x_test)


#Merge both test and training data. 
finalData <- rbind(trainingData, testData)

#
colnames <- colnames(finalData)

#Extract only columns with mean & std deviation
extract <- grep(".*mean.*|.*std.*", features[,2])

finalGoodData <- finalData[,extract]

# 3. Use descriptive activity names to name the activities in the data set
finalGoodData <- merge(finalGoodData, activity_labels, by="activityId", all.x=TRUE)
colnames(finalGoodData)

# 4. Appropriately labels the data set with descriptive variable names
finalGoodData$activityType <- factor(finalGoodData$activityType, labels=c("Walking",
    "Walking Upstairs", "Walking Downstairs", "Sitting", "Standing", "Laying"))

# 5: Creates a second, independent tidy data set with the
# average of each variable for each activity and each subject.

melted <- melt(finalGoodData, id=c("subjectId","activityType"))
tidy <- dcast(melted, subjectId+activityType ~ variable, mean)

# write the tidy data set to a file
write.csv(tidy, "tidy.csv", row.names=FALSE)
write.table(tidy, "tidy.txt", row.names = FALSE)

