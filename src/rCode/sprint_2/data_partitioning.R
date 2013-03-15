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
#   * Inputs: the data_csv directory containing the events and  rsvps csv files
#   * Outputs: the data_output directory with the member_event_partitions.csv file 
# =============================================================================
rm(list = ls())

# =============================================================================
# source() and library()
# =============================================================================
source("src/rCode/common.R")

# =============================================================================
# Function definition
# =============================================================================
CreateMemberEvents <- function(max.members){
  print(noquote("Reading the MEMBER.EVENTs (if there was any)..."))
  member.events <- ReadAllCSVs(dir="data_output/partitions/", obj_name="member_events")
  
  if (is.null(member.events)){
    print(noquote("Creating the MEMBER.EVENTs (no there wasn't)..."))
    print(noquote("    Reading the EVENTs..."))
    events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[, c("id", "time", "venue_id")]
    
    print(noquote("    Selecting the EVENTs with location..."))
    events <- events[!is.na(events$venue_id), c("id", "time")]
    
    print(noquote("    Reading the RSVPs..."))
    rsvps <- ReadAllCSVs(dir="data_csv/", obj_name="rsvps")[, c("member_id", "event_id", "response")]
    
    print(noquote("    Selecting the RSVPs with response equals yes..."))
    rsvps <- rsvps[rsvps$response == "yes", c("member_id", "event_id")]
    
    print(noquote("    Merging the RSVPs with EVENTs table (to add the EVENTs <time>)"))
    member.events <- merge(rsvps, events, 
                          by.x = "event_id", by.y = "id")

    print(noquote(paste("    Fixed number of partitions:", partitions.num)))
    print(noquote(paste("    Selecting the members with at least", partitions.num + 1, "event(s)...")))
    member.count <- count(member.events, "member_id")
    member.count <- member.count[member.count$freq > partitions.num,]
    member.events <- member.events[member.events$member_id %in% member.count$member_id,]

    rm(rsvps, events, member.count)
    
    # Reorganizing the data.frame
    member.events <- member.events[,c("member_id", "event_id", "time")]
    colnames(member.events) <- c("member_id", "event_id", "event_time")
    
    
    print(noquote("    Persisting the member.events..."))
    members <- unique(member.events$member_id)
    data.divisions <- ceil(length(members)/max.members)
    
    for (i in 1:data.divisions){
      indexes <- as.integer(((length(members)/data.divisions) * (i -1)) : 
                              ((length(members)/data.divisions) * i)) + 1
      indexes <- indexes[indexes <= length(members)]
      
      print(noquote(paste("Data Division ", i, "/", data.divisions, " - ", length(indexes), 
                          " members", sep = "")))
      
      print(noquote("    Persisting the member_events data in a csv file..."))
      write.csv(member.events[member.events$member_id %in% members[indexes], ], 
                file = paste("data_output/partitions/member_events_",i,".csv", sep = ""), 
                row.names = F)
    }
  }
  
  return (member.events)
}

PartitionEvents <- function(df, partitions.num){
  partition <- 1:partitions.num
  partition.size <- nrow(df)/(partitions.num + 1)
  train_size <- ceil(partition * partition.size)
  partition.time <- sort(df$event_time)[train_size] + 1  # Add a millisecond to guarantee...
  
  return(data.frame(partition = partition, partition_time = partition.time))
}

# =============================================================================
# Executable Script
# =============================================================================

# -----------------------------------------------------------------------------
# DATA PARTITIONS CREATION                         
# -----------------------------------------------------------------------------

partitions.num <- 4
max.members <- 15000 # "Empirically" selected
dir.create("data_output/partitions/", showWarnings=F)

member.events <- CreateMemberEvents(max.members)

members <- unique(member.events$member_id)
data.divisions <- ceil(length(members)/max.members)

for (i in 1:data.divisions){
  indexes <- as.integer(((length(members)/data.divisions) * (i -1)) : 
                          ((length(members)/data.divisions) * i)) + 1
  indexes <- indexes[indexes <= length(members)]

  print(noquote(paste("Data Division ", i, "/", data.divisions, " - ", length(indexes), 
                      " members", sep = "")))
  
  print(noquote(paste("    Partitioning the member's events (", partitions.num, 
                      " partitions)...", sep = "")))
  partitioned.data <- ddply(member.events[member.events$member_id %in% members[indexes], ], 
                            .(member_id), PartitionEvents, partitions.num, 
                            .parallel=T, .progress="text")
  
  print(noquote("    Persisting the partitions in a csv file..."))
  write.csv(partitioned.data, 
            file = paste("data_output/partitions/member_partitions_", i,".csv", sep = ""), 
            row.names = F)
  
  print(noquote(""))
}
