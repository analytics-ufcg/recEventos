rm(list = ls())

source("src/rCode/common.R")
source("src/rCode/sprint_3/recommender_eval_metrics.R")

rec.files <- list.files("data_output/recommendations/", pattern="recommended_events*")

for (i in 1:length(rec.files)){
  print(noquote(paste("Evaluating the recommended_events_", i, ".csv", sep = "")))
  member.events <- read.csv(paste("data_output/partitions/member_events_", i,
                                  ".csv", sep = ""))
  member.events <- ReadAllCSVs("data_output/partitions/", "member_events")
  recommended.events <- read.csv(paste("data_output/recommendations/recommended_events_", 
                                       i, ".csv", sep = ""))
  
  members_id <- unique(recommended.events$member_id)
  partitions <- unique(recommended.events$partition)
  
  table.result <- NULL
  
  for(m in members_id[1:10]){
    for(p in partitions){
      rec.events <- subset(recommended.events, member_id == m & partition == p)
      test.events <- subset(member.events, event_time > rec.events$p_time & member_id == m)
      
      rec.events <- as.character(t(rec.events[1,4:length(rec.events)]))
      test.events <- as.character(test.events[, "event_id"])
      
      for(rec.size in 1:length(rec.events)){
        precision.result <- Precision(test.events, rec.events[1:rec.size])
        recall.result <- Recall(test.events, rec.events[1:rec.size])
        
        table.result <- rbind(table.result, data.frame(member_id = m, partition = p,
                                                       rec_size = rec.size,
                                                       precision = precision.result, recall = recall.result))
      }
    }
  }
  
  dir.create("data_output/evaluations/", showWarnings=F)
  
  print(noquote("Persisting the recommendation evaluations..."))
  write.csv(table.result, 
            file = paste("data_output/evaluations/rec_events_eval_", i, ".csv", sep = ""), 
            row.names = F)
  
}