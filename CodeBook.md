This is a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data.

## The data source

Original data: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
Original description of the dataset: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
Data Set Information

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

##The data

The dataset includes the following files:

'README.txt'

'features_info.txt': Shows information about the variables used on the feature vector.

'features.txt': List of all features.

'activity_labels.txt': Links the class labels with their activity name.

'train/X_train.txt': Training set.

'train/y_train.txt': Training labels.

'test/X_test.txt': Test set.

'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent.

'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.

'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis.

'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration.

'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second.

## Process details

There are 5 parts:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive activity names.
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Implementation of the above steps
### Prep
zip file with data available at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip is downloaded and extracted in the R Work Directory. 

### Libraries
run_analysis.R file will use  data.table and dplyr library
>library("data.table")
>library("dplyr")

### Read Supporting Metadata
The supporting metadata in this data are the name of the features and the name of the activities. They are loaded into variables feature and activity_labels.

>activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
>features <- read.table("./UCI HAR Dataset/features.txt")[,2]

### Extract the column indices that have either mean or std in list of features.
>extract_features <- grepl("mean|std", features, ignore.case = TRUE)
>features_num<-c(1:length(extract_features))

numbers of columns that we need
>extract_columns_features<-features_num[extract_features]

names of the columns that we need
>extract_columns_features_names <- features[extract_features]

### Read data

Both training and test data sets are split up into subject, activity and features. 
They are present in three different files - X, Y, Subject.
First, read only the column indices that have either mean or std from test and train data sets.

>data_test_extracted <- fread("./UCI HAR Dataset/test/X_test.txt", select = extract_columns_features)
>data_train_extracted <- fread("./UCI HAR Dataset/train/X_train.txt", select = extract_columns_features)

Read subject and activity for both data sets 
>activity_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
>subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

>activity_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
>subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

### Merge data
Merge the training and the test sets to create one data set
>data_all_extracted <- rbind(data_test_extracted, data_train_extracted)
>activity_all <- rbind(activity_test, activity_train)
>subject_all <- rbind(subject_test, subject_train)

### Naming the columns
The columns in the features data set can be named from the metadata in extract_columns_feature_names
>names(data_all_extracted) = as.character(extract_columns_features_names)

Rename columns in data sets with Subject and Activity
>activity_all[,2] = activity_labels[activity_all[,1]]
>names(activity_all) = c("Activity_ID", "Activity_Label")
>names(subject_all) = "Subject"

### Merge all data sets 
The data in features, activity and subject are merged and the complete data is now stored in complete data.
>data <- cbind(subject_all, activity_all, data_all_extracted)

### Appropriately labels the data set with descriptive variable names.
If we check extract_columns_feature_names we can say that the following acronyms can be replaced:
- Acc can be replaced with Accelerometer
- Gyro can be replaced with Gyroscope
- BodyBody can be replaced with Body
- Mag can be replaced with Magnitude
- Character f can be replaced with Frequency
- Character t can be replaced with Time

>names(data)<-gsub("Acc", "Accelerometer", names(data))
>names(data)<-gsub("Gyro", "Gyroscope", names(data))
>names(data)<-gsub("BodyBody", "Body", names(data))
>names(data)<-gsub("Mag", "Magnitude", names(data))
>names(data)<-gsub("^t", "Time", names(data))
>names(data)<-gsub("^f", "Frequency", names(data))
>names(data)<-gsub("tBody", "TimeBody", names(data))
>names(data)<-gsub("-mean()", "Mean", names(data), ignore.case = TRUE)
>names(data)<-gsub("-std()", "STD", names(data), ignore.case = TRUE)
>names(data)<-gsub("-freq()", "Frequency", names(data), ignore.case = TRUE)
>names(data)<-gsub("angle", "Angle", names(data))
>names(data)<-gsub("gravity", "Gravity", names(data))

### Tidy Data
Create tidyData as a data set with average for each activity and subject. Then order data by Subject and Activity_ID
>tidyData <- aggregate(. ~ Subject + Activity_ID + Activity_Label, data, mean)
>tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity_ID),]

### Write tidy data into data file  
Write tidyData into data file tidydata.txt that contains the processed data.
>write.table(tidydata, file = "./tidydata.txt")
