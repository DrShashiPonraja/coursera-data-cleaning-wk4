### run_analysis.R
### Takes a series of measurements derived from people exercising with a smart phone
### combines the 'test' and 'train' data sets into one superset
### extracts from the 'features' (i.e precalculated) means and standard deviations of particular measurements
### melts it into a tidy data set

### notsure if this next part is required, had a read, don't think so
### then goes back to the raw data, calculates the averages for each value measured
### and at long last, produces 2 new data frames
### with the averages for each measure for each subject
### and the averages for each measure for each activity
library(reshape2)

##Step 1. Get Subject_Test.txt and Subject_Train.txt, stick it into one neat frame
##        with the header 'SubjectID'

fileName <- 'UCI HAR Dataset 2/test/subject_test.txt'
SubjectID_TestSet<-read.csv(fileName, header = FALSE)

fileName <- 'UCI HAR Dataset 2/train/subject_train.txt'
SubjectID_TrainSet<-read.csv(fileName, header = FALSE)

names(SubjectID_TestSet)<-'SubjectID'
names(SubjectID_TrainSet)<-'SubjectID'

ActivityMeasures <- rbind(SubjectID_TestSet, SubjectID_TrainSet) 
write.csv((ActivityMeasures),'step1.csv')

##Step 2. Get the list of activities, and stick them into my new data.frame
fileName <- 'UCI HAR Dataset 2/test/y_test.txt'
ActivityID_TestSet<-read.csv(fileName, header = FALSE)

fileName <- 'UCI HAR Dataset 2/train/y_train.txt'
ActivityID_TrainSet<-read.csv(fileName, header = FALSE)

names(ActivityID_TestSet)<-'ActivityID'
names(ActivityID_TrainSet)<-'ActivityID'

ActivityID<-rbind(ActivityID_TestSet,ActivityID_TrainSet)
ActivityMeasures$ActivityID<-ActivityID[,1]


write.csv((ActivityMeasures),'step2.csv')

## Step 3. Get the list of names of the Activities
fileName <- 'UCI HAR Dataset 2/activity_labels.txt'
ActivityNames<-read.csv(fileName, sep = " ", header = FALSE)
names(ActivityNames)<-c('ActivityID', 'ActivityName')

## now run down the list, and label everything..
FindActivityName<-function(x){
  return (ActivityNames$ActivityName[x])
}
ActivityMeasures$ActivityName <- sapply(ActivityMeasures$ActivityID, FindActivityName)

write.csv((ActivityMeasures),'step3.csv')

##Step 4. now we must load the features (i.e precalculated averages)
fileName <- 'UCI HAR Dataset 2/test/X_test.txt'
Features_TestSet<-read.table(fileName, header = FALSE)

fileName <- 'UCI HAR Dataset 2/train/X_train.txt'
Features_TrainSet<-read.table(fileName, header = FALSE)

Measure_Features <- rbind(Features_TestSet, Features_TrainSet)

## and load the feature list, which tells us what values are there
fileName <- 'UCI HAR Dataset 2/features.txt'
Features_List<-read.table(fileName, header = FALSE)

names(Measure_Features)<-Features_List$V2

for (i in names(Measure_Features)){
  if (grepl('Mean|mean|std', i)){
    ##print ('Found a Mean STD')
    ActivityMeasures[[i]]<-Measure_Features[[i]]
    ##print (Measure_Features[[i]][1])
  }else{
    ##print ('No Mean STD here')
  }
}

write.csv((ActivityMeasures),'step4.csv')

## Step 5. finally, we're going to melt all the variables that have averages
## our id variables will be SubjectID | ActivityID | ActivityName

MeanColumns<-NULL
for (x in Features_List$V2){
  if (grepl('mean|Mean',x)){
    MeanColumns<-c(x,MeanColumns)
    #print(x)
  }
}

ActMesIDColumns <- c('SubjectID', 'ActivityName', 'ActivityID')

MeltedActivityMeasures<-melt(ActivityMeasures, id=ActMesIDColumns, measure.vars=MeanColumns)


##verify the final data frame

write.csv(MeltedActivityMeasures, file = 'MeltedActivityMeasures.csv',row.names=TRUE, na="")

write.table(MeltedActivityMeasures, file = 'ActMeasTidyData.txt', row.names=FALSE)

