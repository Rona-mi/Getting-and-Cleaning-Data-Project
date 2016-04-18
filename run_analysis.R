# The libraries used in this operation are data.table and dplyr. 
library("data.table")
library("dplyr")

# zip file available at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip is downloaded and extracted in the R Work Directory.

# work with supporting metadata, that are the name of the features and the name of the activities
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract the column indices that have either mean or std in list of features.
extract_features <- grepl("mean|std", features, ignore.case = TRUE)
features_num<-c(1:length(extract_features))
extract_columns_features<-features_num[extract_features]
extract_columns_features_names <- features[extract_features]

# Read data
# Both training and test data sets are split up into subject, activity and features. 
# They are present in three different files - X, Y, Subject.
# First, read only the column indices that have either mean or std from test and train data sets.
data_test_extracted <- fread("./UCI HAR Dataset/test/X_test.txt", select = extract_columns_features)
data_train_extracted <- fread("./UCI HAR Dataset/train/X_train.txt", select = extract_columns_features)

# Read subject and activity for both data sets 
activity_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

activity_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Merge the training and the test sets to create one data set
data_all_extracted <- rbind(data_test_extracted, data_train_extracted)
activity_all <- rbind(activity_test, activity_train)
subject_all <- rbind(subject_test, subject_train)

#The columns in the features data set can be named from the metadata in extract_columns_feature_names
names(data_all_extracted) = as.character(extract_columns_features_names)

# rename columns in data sets with Subject and Activity
activity_all[,2] = activity_labels[activity_all[,1]]
names(activity_all) = c("Activity_ID", "Activity_Label")
names(subject_all) = "Subject"

# Merge the data
# The data in features, activity and subject are merged and the complete data 
# is now stored in complete data.
data <- cbind(subject_all, activity_all, data_all_extracted)

# Appropriately labels the data set with descriptive variable names.
# - leading t or f is based on Time or Frequency measurements.
# - Body = related to body movement.
# - Gravity = acceleration of gravity
# - Acc = accelerometer measurement
# - Gyro = gyroscopic measurements
# - Jerk = sudden movement acceleration
# - Mag = magnitude of movement
# - mean and SD are calculated for each subject for each activity for each mean and SD measurements. 
#  The units given are g’s for the accelerometer and rad/sec for the gyro and g/sec and rad/sec/sec for the corresponding jerks.
names(data)<-gsub("Acc", "Accelerometer", names(data))
names(data)<-gsub("Gyro", "Gyroscope", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))
names(data)<-gsub("Mag", "Magnitude", names(data))
names(data)<-gsub("^t", "Time", names(data))
names(data)<-gsub("^f", "Frequency", names(data))
names(data)<-gsub("tBody", "TimeBody", names(data))
names(data)<-gsub("-mean()", "Mean", names(data), ignore.case = TRUE)
names(data)<-gsub("-std()", "STD", names(data), ignore.case = TRUE)
names(data)<-gsub("-freq()", "Frequency", names(data), ignore.case = TRUE)
names(data)<-gsub("angle", "Angle", names(data))
names(data)<-gsub("gravity", "Gravity", names(data))

# Create tidyData as a data set with average for each activity and subject. 
# Then order data by Subject and Activity
tidyData <- aggregate(. ~ Subject + Activity_ID + Activity_Label, data, mean)
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity_ID),]

# Write tidyData into data file tidydata.txt that contains the processed data.
write.table(tidydata, file = "./tidydata.txt", row.name=FALSE)
