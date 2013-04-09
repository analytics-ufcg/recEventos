# =============================================================================
#   recommender_run.R
#   Copyright (C) 2013  Augusto Queiroz
# 
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
# =============================================================================
#   * Goal: Runs the recommendations per partition file. The execution
#           is highly parallelizable, running one recommendation job 
#           (that is, calling the RecommendPerPartition function) per 
#           member and partition.
#   * Inputs: The partition csv files
#   * Outputs: The recommendation results in csv files, per algorithm
# =============================================================================
rm(list=ls())

# =============================================================================
# source() and library()
# =============================================================================
source("src/rCode/common.R")
source("src/rCode/sprint_3/recommender_functions.R")

# =============================================================================
# Function definitions
# =============================================================================
RecommendPerPartition <- function(partition, k.events, rec.fun){
  member.id <- partition$member_id
  p.time <- partition$partition_time
  
  # Call the recommender function
  rec.events <- rec.fun(member.id, k.events, p.time)
  
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
algorithms <- c("Weighted") # c("Distance", "Popularity", "Topic", "Weighted")

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
    
    rec.events.df <- ddply(idata.frame(partitions), .(member_id, partition),
                           RecommendPerPartition, k, .parallel = T, .progress = "text",
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
