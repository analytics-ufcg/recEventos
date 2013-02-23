# =============================================================================
# Copyright (C) 2013 Augusto Queiroz, Elias Paulino, Rodolfo Moraes, 
#                    Ricardo Araujo e Leandro Balby
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal 
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#     
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
# SOFTWARE.
#
# Author: Augusto Queiroz
#
# File: partition_data.R
#   * Description: This file partition the events chronologically in 10 different
#                  data splits of train/test. Then a figure is generated to 
#                  support the partition quality analysis
#   * Inputs: the data_csv directory containing the events, rsvps and group csv 
#             files
#   * Outputs: the data_output directory with the data_partitions.csv file 
#              containing the events by city partitioned chronologically and; the 
#              data_partition_analysis-member_count.png figure with histograms
#              that support the analysis of the partitions by counting the  
#              members per data split (train and test).
# =============================================================================

rm(list=ls())

# =============================================================================
# source() and library()
# =============================================================================
library(lubridate)
library(plyr)
library(ggplot2)

# =============================================================================
# Function definitions
# =============================================================================

PartitionEvents <- function(df){
  df.final = NULL
  for(q in seq(.1, 1, .1)){
    result <- rep("train", nrow(df))
    result[df$time >= quantile(df$time, q)] <- "test"
    result <- factor(result,levels=c("train", "test"))
    
    df$partition <- paste(q, sep = "")
    df$data_split <- result
    
    df.final <- rbind(df.final, df)
  }
  return(df.final)
}

# =============================================================================
# Executable Script
# =============================================================================

# -----------------------------------------------------------------------------
# DATA PARTITIONS CREATION                         
# Partitioning the events by CITY, CHRONOLOGICALLY 
# -----------------------------------------------------------------------------

events <- read.csv("data_csv/events_1.csv")
groups <- read.csv("data_csv/groups.csv")
rsvps <- read.csv("data_csv/rsvps_1.csv")
# venues <- read.csv("data_csv/venues.csv")

# Add the city of the VENUE (if there isn't venues, the event is excluded)
# events.with.city <- merge(events[!is.na(events$venue_id), c("id", "time", "venue_id")],
#                           venues[,c("id", "city")], 
#                           by.x = "venue_id", 
#                           by.y = "id", 
#                           all.x = T)
# Not used because there are divergences in the Venue city names...

# Add the citiy of the GROUP to all events from that group
events.with.city <- merge(events[,c("id", "time", "group_id")],
                          groups[,c("id", "city")], 
                          by.x="group_id", 
                          by.y = "id", 
                          all.x = T)

# Partition the events chronologically
event.partitions <- ddply(events.with.city, .(city), PartitionEvents)

# Organize and persist the data.frame in a csv file
event.partitions <- event.partitions[order(event.partitions$city, 
                                           event.partitions$partition),]
event.partitions <- event.partitions[,c("city", "partition", "data_split", "id")]
colnames(event.partitions) = c("city", "partition", "data_split", "event_id")

# Persist the data.frame
dir.create("data_output", showWarnings=F)
write.csv(event.partitions, file = "data_output/data_partitions.csv", row.names = F)


# -----------------------------------------------------------------------------
# DATA PARTITION ANALYSIS - Count the MEMBERS per DATA SPLIT
# -----------------------------------------------------------------------------

# Count the quantity of members that attended the events (rsvp = yes)
rsvp.members.per.event <- count(rsvps[rsvps$response == "yes",], vars="event_id")
colnames(rsvp.members.per.event) <- c("event_id", "member_count")

# Merge the member count with the partitioned events
partition.member.count <- merge(event.partitions, rsvp.members.per.event, 
                                by="event_id", all.x = T)
partition.member.count[is.na(partition.member.count$member_count),"member_count"] <- 0

# Image with the Events Count per (city, partition and data_split)
png("data_output/data_partition_analysis-event_count.png", width=1000, height=800)
print(ggplot(partition.member.count, aes(x = partition, fill = data_split)) + 
        geom_bar(position = "dodge", width = .65) + 
        facet_wrap(~ city, scales="free_y") + 
        xlab("time percentage partition") + ylab("members count"))
dev.off()

# TODO (augusto): Image with the Members Count per (city, partition and data_split)
png("data_output/data_partition_analysis-event_count.png", width=1000, height=800)
print(ggplot(partition.member.count, aes(x = partition, fill = data_split)) + 
        geom_bar(position = "dodge", width = .65) + 
        facet_wrap(~ city, scales="free_y") + 
        xlab("time percentage partition") + ylab("members count"))
dev.off()
