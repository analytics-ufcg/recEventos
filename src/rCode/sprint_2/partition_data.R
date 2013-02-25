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
source("src/rCode/common.R")

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

print(noquote("Reading all events and groups..."))
events <- ReadAllCSVs(dir="data_csv/", obj_name="events")
groups <- read.csv("data_csv/groups.csv")
# venues <- read.csv("data_csv/venues.csv")

# Add the city of the VENUE (if there isn't venues, the event is excluded)
# events.with.city <- merge(events[!is.na(events$venue_id), c("id", "time", "venue_id")],
#                           venues[,c("id", "city")], 
#                           by.x = "venue_id", 
#                           by.y = "id", 
#                           all.x = T)
# Not used because there are divergences in the Venue city names...

# Add the city of the GROUP to all events from that group
print(noquote("Adding the city to the events table..."))
events.with.city <- merge(events[,c("id", "time", "group_id")],
                          groups[,c("id", "city")], 
                          by.x="group_id", 
                          by.y = "id", 
                          all.x = T)
rm(events, groups)

print(noquote("Reading all rsvps..."))
rsvps <-  ReadAllCSVs(dir="data_csv/", obj_name="rsvps")

# Count the quantity of members that attended the events (rsvp = yes)
print(noquote("Counting the members with RSVP per event..."))
rsvp.members.per.event <- count(rsvps[rsvps$response == "yes",], vars="event_id")
colnames(rsvp.members.per.event) <- c("event_id", "member_count")

rm(rsvps)


# Merge the events_with_city and the member_count per event
print(noquote("Merging the events with city and the members count..."))
events.with.city.members <- merge(events.with.city, rsvp.members.per.event, 
                                  by.x="id", by.y="event_id", all.x = T)

# Delete events without members with RSVP
print(noquote("Removing the events without members..."))
events.with.city.members <- events.with.city.members[!is.na(events.with.city.members$member_count),]

rm(events.with.city, rsvp.members.per.event)

# Partition the events chronologically
print(noquote("Partitioning the events chronologically by city..."))
registerDoMC()
event.partitions <- ddply(events.with.city.members, .(city), PartitionEvents, .parallel=T)

rm(events.with.city.members)

# Organize the data.frame
event.partitions <- event.partitions[order(event.partitions$city, 
                                           event.partitions$partition,
                                           event.partitions$data_split,
                                           event.partitions$member_count),]
event.partitions <- event.partitions[,c("city", "partition", "data_split", "id", "member_count")]
colnames(event.partitions) = c("city", "partition", "data_split", "event_id", "member_count")

# Persist the data.frame in a csv file
print(noquote("Persisting the data_partitions in a csv file..."))
dir.create("data_output", showWarnings=F)
write.csv(event.partitions, file = "data_output/data_partitions.csv", row.names = F)

# -----------------------------------------------------------------------------
# DATA PARTITION ANALYSIS - Count the MEMBERS per DATA SPLIT
# -----------------------------------------------------------------------------

# Image with the Members Count per (city, partition and data_split)
print(noquote("Generating bar charts by city with the member count per partitions and data_split"))
png("data_output/data_partition_analysis-member_count.png", width=4000, height=2000)
print(ggplot(event.partitions, aes(x = partition, fill = data_split)) + 
        geom_bar(aes(weight = member_count), position = "dodge", width = .6) + 
        facet_wrap(~ city, , scales="free_y")  + 
        xlab("time percentage partition") + ylab("members count"))
dev.off()
