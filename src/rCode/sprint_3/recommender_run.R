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
#                  member and partition.
#   * Inputs: The partition csv files
#   * Outputs: The recommendation results in csv files, per algorithm
# =============================================================================
rm(list=ls())

# =============================================================================
# source() and library()
# =============================================================================
source("src/rCode/common.R")
#source("src/rCode/sprint_3/recommender_functions.R")
source("src/rCode/sprint_4/algoritmo_categoria_eventos_freq.R")

# =============================================================================
# Function definitions
# =============================================================================
RecommendPerPartition <- function(partition, k, rec.fun){
  member.id <- partition$member_id
  p.time <- partition$partition_time
  
  # Call the recommender function
  rec.events <- rec.fun(member.id, k, p.time)
  
  return(cbind(data.frame(p_time = p.time), t(rec.events)))
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
algorithms <- c("Topic") # c("Distance", "Popularity", "Topic", "Weighted")

rec.environment <- CreateRecEnvironment()

for (rec.fun.name in algorithms){
  cat("Running RecEvents.", rec.fun.name, "...\n", sep="")
  rec.fun <- match.fun(paste("RecEvents.", rec.fun.name, sep = ""))
  
  cat("Sharing Recommender Environment...\n")
  environment(rec.fun) <- rec.environment
  
  for (i in 1:length(partition.files)){
    file <- partition.files[i]
    
    cat("  Partition file:", file, "\n")
    partitions <- read.csv(paste(partition.dir, file, sep =""))

    print(noquote(paste("   Started running at: ", Sys.time(), sep = "")))
    
    rec.events.df <- ddply(idata.frame(partitions[1:200,]), .(member_id, partition),
                           RecommendPerPartition, k, .parallel = F, .progress = "text",
                           rec.fun)
    rec.events.df$algorithm <- rep(rec.fun.name, nrow(rec.events.df))
    
    print(noquote(paste("   Finished running at: ", Sys.time(), sep = "")))

    # Organize the columns
    rec.events.df <- rec.events.df[,c(1:3, ncol(rec.events.df), 4:(ncol(rec.events.df)-1))]
    
    persist.file <- paste("rec_events_", tolower(rec.fun.name), "_",  i, ".csv", sep = "")
    cat("    Persisting the results:", persist.file, "\n")
    write.csv(rec.events.df, file=paste(output.dir, persist.file, sep =""), row.names = F)
  }
}
