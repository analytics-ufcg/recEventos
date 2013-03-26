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
# Function definition
# =============================================================================
RecommendPerPartition <- function(partition, k, algorithm = "Distance"){
  member.id <- partition$member_id
  
  p.time <- partition$partition_time
  if (algorithm == "Distance"){
    rec.events <- RecEvents.Distance(member.id, k, p.time)
  }
  if (algorithm == "Topic"){
    #     rec.events <- RecEventsByTopic (member.id, k, p.time)
  }
  if (algorithm == "Weighted"){
    #     rec.events <- RecEventsWeighting (rec.events.distance, rec.events.topic)
  }
  return(cbind(data.frame(p_time = p.time, algorithm = algorithm), t(rec.events)))
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

# TODO (Augusto): Propagar mudanças para eval e analysis

# Number of recommended events
k <- 5
algorithms <- c("Distance"))

for (alg in algorithms){
  cat("Recommending with:", alg)

  # Call the SetEnvironment of the algorithm
  match.fun(paste("SetEnvironment.", alg, sep = ""))()
  
  for (i in 1:length(partition.files)){
    file <- partition.files[i]
    
    cat("Partition file:", file)
    partitions <- read.csv(paste(partition.dir, file, sep =""))
    
    cat("    Start recommending...")
    rec.events.df <- ddply(idata.frame(partitions), .(member_id, partition),
                           RecommendPerPartition, k, .parallel = T, .progress = "text",
                           alg)
    
    persist.file <- paste("rec_events_", tolower(alg), "_",  i, ".csv", sep = "")
    cat("    Persisting the results:", persist.file)
    write.csv(rec.events.df, file=paste(output.dir, persist.file, sep =""), row.names = F)
  }

  # Clean the Environment of the algorithm 
  cat("Cleaning the Algorithm Environment")
  algEnv <- environment(match.fun(paste("RecEvents.", alg, sep = "")))
  rm(list = ls(envir=algEnv), envir=algEnv)
  gc()
}