rm(list = ls())

source("src/rCode/common.R")
source("src/rCode/sprint_3/recommender_alg_distance.R")

# For each partition file
#   Lê o arquivo de partições
#   For each member
#     # Run the recommender
#     recEvents <- KNearestEvents (member_id, partition_time)
# 
#     # Append the result (partition and its evaluations) in a data.frame

partition.dir <- "data_output/partitions/"
partition.files <- list.files(partition.dir, pattern="member_partitions_*")

# TODO (augusto): ler todos os arquivos de particoes
i <- 1
partitions <- read.csv(paste(partition.dir, partition.files[i], sep =""))

member.ids <- unique(partitions$member_id)
partition.ids <- 1:10
rec.events.list <- NULL
k <- 10

print(noquote("Start recommeding"))
dir.create("data_output/recommendations/", showWarnings=F)

# TODO (augusto): colocar em paralelo com foreach
for(m in member.ids[1:10]){
  print(noquote(m))
  
  # TODO (augusto): Change this inner loop into a function call (alply or something)
  for (p in partition.ids){
    print(noquote(p))
    
    p.time <- unique(partitions[partitions$member_id == m & partitions$partition == p, 
                                "partition_time"])

    # Run the recommender
    rec.events <- KNearestEvents (m, k, p.time)
    
    # Add the recommended events to the result list
    rec.events.list[["members"]][[paste(m)]][["partitions"]][[paste(p)]]$p.time <- p.time
    rec.events.list[["members"]][[paste(m)]][["partitions"]][[paste(p)]]$rec.events <- rec.events
  }
}

print(noquote("Persisting the recommendation results..."))
save(rec.events.list, file=paste("data_output/recommendations/recommeded_events_",i,".dat", sep = ""))
