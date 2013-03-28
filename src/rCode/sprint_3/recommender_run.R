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
# File: recommender_run.R
#   * Description: Runs the recommendations per partition file. The execution
#                  is highly parallelizable, running one recommendation job 
#                  (that is, calling the RecommendPerPartition function) per 
#                  member and partition, that means 10 executions per member this
#                  sums up to the number of rows of all partition files together,
#                  (something like 903,500 jobs!).
#   * Inputs: The partition csv files
#   * Outputs: The recommendation results in csv files
# =============================================================================
rm(list=ls())

# =============================================================================
# source() and library()
# =============================================================================
source("src/rCode/common.R")
source("src/rCode/sprint_3/recommender_alg_distance.R")

# =============================================================================
# Function definitions
# =============================================================================
CreateAndShareRecEnvironment <- function(){
  cat("Creating the Recommendation Environment...\n")
  
  cat("  Reading the member.events...\n")
  member.events <- data.table(ReadAllCSVs("data_output/partitions/", "member_events"))
  
  cat("  Reading the members...\n")
  members <- data.table(ReadAllCSVs(dir="data_csv/", obj_name="members")[,c("id","lat","lon")])
  setkey(members, "id")
  setkey(member.events, "member_id")
  members <- subset(members, id %in% unique(member.events$member_id))
  
  cat("  Reading the events...\n")
  events <- data.table(ReadAllCSVs(dir="data_csv/", obj_name="events")[,c("id", "created", "time", "venue_id")])
  setkey(events, "venue_id")
  setkey(member.events, "event_id")
  events <- subset(events, id %in% unique(member.events$event_id))
  
  cat("  Reading the venues...\n")
  venues <- data.table(read.csv("data_csv/venues.csv",sep = ",")[,c("id", "lat", "lon")])
  setnames(venues, old=1, new="venue_id")
  setkey(venues, "venue_id")
  
  cat("  Filtering the events with location...\n")
  events.with.location <- merge(events, venues)
  events.with.location$lat <- NULL
  events.with.location$lon <- NULL
  events.with.location$id <- as.character(events.with.location$id)
  
  # Just to order and make the subset in the distance algorithm faster
  setkey(events.with.location, "created")
  
  rm(member.events, events)

  # Share Environment is the same as: This function environment will be the 
  # environment of the RecEvents.Distance function (this is different from its 
  # evaluation environment, created during its evaluation)
  # The special assignment operator (<<-) is used to force the assignment occur 
  # in the RecEvents.Distance actual environment, not as a temp variable in this 
  # evaluation environment
  cat("  Sharing Environment with algorithms...\n")
  environment(RecEvents.Distance) <<- environment()
  
}

RecommendPerPartition <- function(partition, k, rec.fun, rec.fun.name){
  member.id <- partition$member_id
  p.time <- partition$partition_time
  
  # Call the recommender function
  rec.events <- rec.fun(member.id, k, p.time)
  
  return(cbind(data.frame(p_time = p.time, algorithm = rec.fun.name), t(rec.events)))
}

# =============================================================================
# Main
# =============================================================================

output.dir <- "data_output/recommendations/"
dir.create(output.dir, showWarnings=F)

partition.dir <- "data_output/partitions/"
partition.files <- list.files(partition.dir, pattern="member_partitions_*")

# Force the data partition execution (if it wasn't done yet...)
if (length(partition.files) <= 0){
  stop(paste("There is no partition file in \"", partition.dir, 
             "\" (run the \"src/rCode/sprint_2/data_partitioning.R\" to create the partitions)", sep = ""))
}

# Number of recommended events
k <- 5
algorithms <- c("Distance") # c("Distance", "Popularity", "Topic", "Weighted")

CreateAndShareRecEnvironment()

for (rec.fun.name in algorithms){
  cat("Recommending with:", rec.fun.name, "\n")
  
  rec.fun <- match.fun(paste("RecEvents.", rec.fun.name, sep = ""))
  
  for (i in 2:length(partition.files)){
    file <- partition.files[i]
    
    cat("Partition file:", file, "\n")
    partitions <- read.csv(paste(partition.dir, file, sep =""))

    print(noquote(paste("    Started running at: ", Sys.time(), sep = "")))
    
    rec.events.df <- ddply(idata.frame(partitions[1:3,]), .(member_id, partition),
                           RecommendPerPartition, k, .parallel = F, .progress = "text",
                           rec.fun, rec.fun.name)
    
    print(noquote(paste("    Finished running at: ", Sys.time(), sep = "")))
    
    persist.file <- paste("rec_events_", tolower(rec.fun.name), "_",  i, ".csv", sep = "")
    cat("    Persisting the results:", persist.file, "\n")
    write.csv(rec.events.df, file=paste(output.dir, persist.file, sep =""), row.names = F)
  }
}
