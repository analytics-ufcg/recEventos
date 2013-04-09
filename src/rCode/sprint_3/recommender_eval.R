# =============================================================================
#   recommender_eval.R
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
#   * Goal: 
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

attach(CreateRecEnvironment())

# The member_events is the unique that is always the same
member.events <- ReadAllCSVs("data_output/partitions/", "member_events")
algorithms <- c("weighted") # c("distance", "popularity", "topic", "weighted")

for (alg in algorithms){
  cat("Evaluating the", alg, "algorithm...\n")
  
  alg.files <- list.files("data_output/recommendations/", pattern=paste("rec_events_", alg, "_", sep=""))
  
  for (i in 1:length(alg.files)){
    cat("  Rec file ", i, "...\n", sep = "")
    recommended.events <- read.csv(paste("data_output/recommendations/", alg.files[i], sep=""))
    
    all.recs <- ddply(recommended.events, .(member_id, partition), function(rec.events.row){
      m <- rec.events.row$member_id
      p <- rec.events.row$partition
      p.time <- rec.events.row$p_time
      
      # Define the recommendation set
      rec.events <- as.character(t(rec.events.row[1, 5:length(rec.events.row)]))
      
      # Define the test set
      all.candidate.events <- subset(events.with.location, 
                                     created <= p.time & time >= p.time)$id
      all.member.events <- subset(member.events, member_id == m)$event_id
      test.events <- all.member.events[all.member.events %in% all.candidate.events]
      
      # Measure the PRECISION and RECALL for each recommendation size (from 1 to length(recommendations))
      rec.result <- foreach(rec.size = 1:length(rec.events), .combine = rbind) %do% {
        data.frame(member_id = m, partition = p, rec_size = rec.size, 
                   precision = Precision(test.events, rec.events[1:rec.size]), 
                   recall = Recall(test.events, rec.events[1:rec.size]))
      }
      rec.result$candidate_events_num <- rep(length(all.candidate.events), nrow(rec.result))
      rec.result$member_events_num <- rep(length(all.member.events), nrow(rec.result))
      rec.result$test_events_num <- rep(length(test.events), nrow(rec.result))
      
      rec.result
    })
    
    all.recs$algorithm <- rep(alg, nrow(all.recs))
    
    cat("    Persisting the recommendation evaluations...\n")
    write.csv(all.recs, 
              file = paste("data_output/evaluations/rec_events_", alg, 
                           "_eval_", i, ".csv", sep = ""), row.names = F)
  }
}
