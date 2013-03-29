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
# File: 
#   * Description: 
#   * Inputs: 
#   * Outputs:
# =============================================================================
rm(list = ls())

# =============================================================================
# source() and library()
# =============================================================================
source("src/rCode/common.R")
source("src/rCode/sprint_3/recommender_functions.R")
source("src/rCode/sprint_3/recommender_eval_metrics.R")

# =============================================================================
# Main
# =============================================================================

dir.create("data_output/evaluations/", showWarnings=F)

rec.environment <- CreateRecEnvironment()

# The member_events is the unique the is always the same
member.events <- ReadAllCSVs("data_output/partitions/", "member_events")
algorithms <- c("distance") # c("distance", "popularity", "topic", "weighted")

for (alg in algorithms){
  cat("Evaluating the", alg, "algorithm...\n")
  
  alg.files <- list.files("data_output/recommendations/", pattern=paste("rec_events_", alg, "_", sep=""))
  
  for (i in 1:length(alg.files)){
    cat("  Rec file ", i, "...\n", sep = "")
    recommended.events <- read.csv(paste("data_output/recommendations/", alg.files[i], sep=""))
    
    table.result <- foreach(rec.events.row = iter(recommended.events[1:10,], by='row'), .combine = rbind) %do% {
      m <- rec.events.row$member_id
      p <- rec.events.row$partition
      p.time <- rec.events.row$p_time
      
      # Define the recommendation set
      rec.events <- as.character(t(rec.events.row[1, 5:length(rec.events.row)]))
      
      # Define the test set
      all.candidate.events <- subset(rec.environment$events.with.location, 
                                     created <= p.time & time >= p.time)$id
      all.member.events <- subset(member.events, member_id == m)$event_id
      test.events <- all.member.events[all.member.events %in% all.candidate.events]
      
      # Measure the PRECISION and RECALL for each recommendation size (from 1 to length(recommendations))
      foreach(rec.size = 1:length(rec.events), .combine = rbind) %do% {
        data.frame(member_id = m, partition = p, rec_size = rec.size, algorithm = alg,
                   candidate_events_num = length(all.candidate.events),
                   member_events_num = length(all.member.events),
                   test_events_num = length(test.events),
                   precision = Precision(test.events, rec.events[1:rec.size]), 
                   recall = Recall(test.events, rec.events[1:rec.size]))
      }
    }
    # The result of the inner loop is returned
    
    cat("    Persisting the recommendation evaluations...\n")
    write.csv(table.result, 
              file = paste("data_output/evaluations/rec_events_", alg, "_eval_", i, ".csv", sep = ""), 
              row.names = F)
  }
}
