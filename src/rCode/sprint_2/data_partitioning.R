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
# =============================================================================
#
# Author: Augusto Queiroz
#
# File: partition_data.R
#   * Description: This file partition the events of a member chronologically 
#                  in 10 sequential data splits of train/test. 
#   * Inputs: the data_csv directory containing the events, rsvps and group csv 
#             files
#   * Outputs: the data_output directory with the data_partitions.csv file 
#              containing the events partitioned chronologically
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
  
  # for each df, 10 repetitions are generated with the partition and data_split
  # collumns added
  for(q in seq(.1, 1, .1)){
    partition_time <- quantile(df$event_time, q, na.rm=T)
    
    data_split <- rep("train", nrow(df))
    data_split <- factor(data_split, levels=c("train", "test"))
    data_split[df$event_time >= partition_time] <- "test"
    
    df$partition <- q
    df$partition_time <- partition_time
    df$data_split <- data_split
    
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

print(noquote("Reading the EVENTs and RSVPs..."))
# events <- read.csv("data_csv/events_10.csv")[, c("id", "time")]
events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[, c("id", "time")]
# rsvps <- read.csv("data_csv/rsvps_10.csv")[, c("member_id", "event_id", "response")]
rsvps <- ReadAllCSVs(dir="data_csv/", obj_name="rsvps")[, c("member_id", "event_id", "response")]

print(noquote("Selecting the RSVPs with response equals yes..."))
rsvps <- rsvps[rsvps$response == "yes", c("member_id", "event_id")]

print(noquote("Merging the RSVP events with the EVENTs time"))
rsvps.events <- merge(rsvps, events, 
                      by.x = "event_id", by.y = "id",
                      all.x = T)
rm(rsvps, events)
gc()

# Reorganizing the data.frame
colnames(rsvps.events) <- c("member_id", "event_id", "time")
colnames(rsvps.events) <- c("member_id", "event_id", "event_time")

print(noquote("Partitioning the member's events chronologically..."))
members <- unique(rsvps.events$member_id)

for (i in 1:10){
  member.events.partitions <- members
  
  print(noquote(paste("Partitioning the member's events chronologically (", i,")...", sep = "")))
  indexes <- as.integer(((length(members)/10) * (i -1)):((length(members)/10) * i)) + 1
  member.events.partitions <- ddply(rsvps.events[indexes,], .(member_id), PartitionEvents, .parallel=F, .progress="text")

  print(noquote(paste("Organizing the resultant data (", i,")...", sep = "")))
  member.events.partitions <- member.events.partitions[order(member.events.partitions$member_id, 
                                                             member.events.partitions$partition,
                                                             member.events.partitions$data_split),]
  
  print(noquote(paste("Persisting the data in a csv file (", i,")...", sep = "")))
  dir.create("data_output/partitions/", showWarnings=F)
  write.csv(member.events.partitions, file = paste("data_output/partitions/member_events_partitions_",i,".csv", sep = ""), row.names = F)
}
