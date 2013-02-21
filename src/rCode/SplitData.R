# Particiona os dados em treino e teste cronologicamente. 
# Para cada cidade, 
# criar 10 partições com diferentes proporções treino-teste no tempo.
rm(list=ls())
library(lubridate)
library(plyr)

PartitionEvents <- function(df){
  df.final = NULL
  for(q in seq(.1, 1, .1)){
    result <- rep("train", nrow(df))
    result[df$time >= quantile(df$time, q)] <- "test"
    result <- factor(result,levels=c("train", "test"))
    
    df$partition <- paste("partition_", q, sep = "")
    df$data_split <- result
    
    df.final <- rbind(df.final, df)
  }
  return(df.final)
}

CountMembersPerPartition <- function(df, rsvps){
  df$members_count <- nrow(rsvps[rsvps$event_id %in% df$id,])
  return(df)
}

events <- read.csv("data_csv/events_1.csv")
venues <- read.csv("data_csv/venues.csv")
groups <- read.csv("data_csv/groups.csv")
members <- read.csv("data_csv/members.csv")
rsvps <- read.csv("data_csv/rsvps_1.csv")

# Add the citiy of the GROUP to all events from that group
events.with.city <- merge(events[,c("id", "time", "group_id")], groups[,c("id", "city")], by.x="group_id", by.y = "id", all.x = T)

# Partition the events chronologically
events.partitioned <- ddply(events.with.city, .(city), PartitionEvents)

# Count the quantity of members per c(city, partition and data_split)
events.partitioned <- ddply(events.partitioned, .(city, partition, data_split), CountMembersPerPartition, rsvps)