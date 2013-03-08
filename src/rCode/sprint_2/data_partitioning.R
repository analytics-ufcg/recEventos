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

rm(list=ls())

# =============================================================================
# source() and library()
# =============================================================================
source("src/rCode/common.R")

# =============================================================================
# Function definition
# =============================================================================

PartitionEvents <- function(df){
  partition <- 1:10
  partition_time <- quantile(df$event_time, seq(.1, 1, .1), na.rm=T)
  train_size <- sapply(partition_time, function(p)sum(df$event_time >= p))

  return(data.frame(partition, partition_time, train_size))
}

# =============================================================================
# Executable Script
# =============================================================================

# -----------------------------------------------------------------------------
# DATA PARTITIONS CREATION                         
# -----------------------------------------------------------------------------

print(noquote("Reading the EVENTs and RSVPs..."))
events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[, c("id", "time", "venue_id")]
rsvps <- ReadAllCSVs(dir="data_csv/", obj_name="rsvps")[, c("member_id", "event_id", "response")]
# 
print(noquote("Selecting the EVENTs with location..."))
events <- events[!is.na(events$venue_id), c("id", "time")]

print(noquote("Selecting the RSVPs with response equals yes..."))
rsvps <- rsvps[rsvps$response == "yes", c("member_id", "event_id")]

print(noquote("Merging the RSVP events with the EVENTs time"))
rsvps.events <- merge(rsvps, events, 
                      by.x = "event_id", by.y = "id")
rm(rsvps, events)

# Reorganizing the data.frame
rsvps.events <- rsvps.events[,c("member_id", "time")]
colnames(rsvps.events) <- c("member_id", "event_time")

gc()

print(noquote("Partitioning the member events chronologically"))
partitioned.data <- ddply(rsvps.events, .(member_id), PartitionEvents, .parallel=T)

print(noquote("Persisting the data in a csv file..."))
dir.create("data_output/", showWarnings=F)
write.csv(partitioned.data, 
          file = "data_output/member_events_partitions.csv", row.names = F)
