rm(list = ls())

source("src/rCode/common.R")
source("src/rCode/sprint_3/recommender_alg_distance.R")

partition.dir <- "data_output/partitions/"
partition.files <- list.files(partition.dir, pattern="member_partitions_*")

# TODO (augusto): ler todos os arquivos de particoes
i <- 1
partitions <- read.csv(paste(partition.dir, partition.files[i], sep =""))

member.ids <- unique(partitions$member_id)

print(noquote("Start recommeding"))
dir.create("data_output/recommendations/", showWarnings=F)

RecommendPerPartition <- function(partition, m, k){
  p.time <- partition$partition_time
  rec.events <- KNearestEvents (m, k, p.time)
  return(list(p.time = p.time, rec.events = rec.events))
}

RecommendPerPartition2 <- function(partition, m, k){
  p.time <- partition$partition_time
  rec.events <- KNearestEvents (m, k, p.time)
  return(cbind(data.frame(p.time = p.time), t(rec.events)))
}

# rec.events.list <- foreach(m = member.ids[1024:1027]) %dopar%
# {
#   list(member.id = m, 
#        partitions = dlply(partitions[partitions$member_id == m, c("partition", "partition_time")], 
#                           .(partition), RecommendPerPartition, m, k))
# }

k <- 10
rec.events.df <- ddply(partitions[1:100,], .(member_id, partition), 
                       RecommendPerPartition2, m, k, .parallel = T)

print(noquote("Persisting the recommendation results..."))
write.csv(rec.events.df, 
          file=paste("data_output/recommendations/recommeded_events_",i,".dat", sep = ""),
          row.names = F))


