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
source("src/rCode/sprint_3/recommender_eval_metrics.R")

# =============================================================================
# Main
# =============================================================================

rec.files <- list.files("data_output/recommendations/", pattern="recommended_events*")

for(i in 1:length(rec.files)) {
  
  print(noquote(paste("Evaluating the recommended_events_", i, ".csv", sep = "")))
  member.events <- read.csv(paste("data_output/partitions/member_events_", i,
                                  ".csv", sep = ""))
  member.events <- ReadAllCSVs("data_output/partitions/", "member_events")
  recommended.events <- read.csv(paste("data_output/recommendations/recommended_events_", 
                                       i, ".csv", sep = ""))
  
  table.result <- foreach(rec.events.row = iter(recommended.events, by='row'), .combine = rbind) %do% {
    # Select the recommendation and test sets
    m <- rec.events.row$member_id
    p <- rec.events.row$partition
    
    # Define the recommendation and test sets as arrays
    rec.events <- as.character(t(rec.events.row[1, 4:length(rec.events.row)]))
    test.events <- as.character(member.events[member.events$event_time > rec.events.row$p_time & 
                                                member.events$member_id == m, "event_id"])
    
    
    # Measure the PRECISION and RECALL for each recommendation size (from 1 to length(recommendations))
    foreach(rec.size = 1:length(rec.events), .combine = rbind) %do% {
      data.frame(member_id = m, partition = p, rec_size = rec.size,
                 precision = Precision(test.events, rec.events[1:rec.size]), 
                 recall = Recall(test.events, rec.events[1:rec.size]))
    }
  }
  # The result of the inner loop is returned
  
  dir.create("data_output/evaluations/", showWarnings=F)
  
  print(noquote("Persisting the recommendation evaluations..."))
  write.csv(table.result, 
            file = paste("data_output/evaluations/rec_events_eval_", i, ".csv", sep = ""), 
            row.names = F)
}
