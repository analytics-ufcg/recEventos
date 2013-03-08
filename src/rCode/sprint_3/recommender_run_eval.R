rm(list = ls())

source("src/rCode/common.R")
source("src/rCode/sprint_3/dist_user_event.R")

# For each partition file
#   Lê um arquivo de partições
#   For each partition
#     # Run the recommender
#     recEvents <- KNearestEvents (member_id, partition_time)
# 
#     # Evaluate the result
#     recall <- recall(test_events, recEvents) # For all relevant events
#     precision <- precision(test_events, recEvents) # For all relevant events
#     ndcg <- recall(test_events, recEvents)
# 
#     # Append the result (partition and its evaluations) in a data.frame

partitions.dir <- "data_output/partitions/"
partitions.files <- list.files(partitions.dir)

# for(f in partition.files){
f <- partitions.files[1]    
partitions <- read.csv(paste(partitions.dir, f, sep = ""))

member.ids <- unique(partitions$member_id)
partition.ids <- unique(partitions$partition)

result <- NULL
k <- 5

print(noquote("Start recommeding"))

# TODO (augusto): colocar em paralelo com foreach
for(m in member.ids[1:10]){
  print(noquote(m))
  for (p in partition.ids){
    print(noquote(p))
    partition.data <- partitions[partitions$member_id == m & partitions$partition == p, ]
    partition.data$event_id <- as.character(partition.data$event_id)
    
    p.time <- unique(partition.data$partition_time)
    test.events <- partition.data$event_id
    
    #     # Run the recommender
    rec.events <- KNearestEvents (m, k, p.time)

    #     # Evaluate the result
    #     precision <- precision(test.events, rec.events) # For all relevant events
    #     recall <- recall(test.events, rec.events) # For all relevant events
    #     ndcg <- recall(test.events, rec.events)
    # 
    #     # Append the result (partition and its evaluations) in a data.frame
    
    result <- rbind(result, data.frame(m, p, 0, 0, 0))
  }
}
# }

