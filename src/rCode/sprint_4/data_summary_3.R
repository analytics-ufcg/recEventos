rm(list = ls())
source("src/rCode/common.R")
source("src/rCode/sprint_3/recommender_functions.R")

filename <- "data_output/evaluations/analysis/member_events_dists.csv"

if (!file.exists(filename)){
  
  cat("Read the Member Events (already filtered)")
  member.events <- data.table(ReadAllCSVs(dir="data_output/partitions/", obj_name="member_events"))
  setkey(member.events, "member_id")
  
  attach(CreateRecEnvironment())
  setkey(events.with.location, "id")
  
  cat("Calculating the member-event distances...")
  dists <- foreach(member = iter(members, by = "row"), .combine = rbind) %do% {
    my.events.ids <- as.character(subset(member.events, member_id == member$id)$event_id)
    my.events <- events.with.location[my.events.ids]
    dists <- geodDist(my.events$lat, my.events$lon, member$lat, member$lon)
    
    data.frame(member=rep(member$id, length(dists)), 
               event_id = my.events.ids, 
               dist_km = dists)
  }
  
  write.csv(dists, file = filename, row.names = F)
}else{
  dists <- read.table(file = filename, header=T, sep = ",", 
                      stringsAsFactors=F, comment.char="",
                      colClasses = c("integer", "character", "numeric"))  
}

# PLOT a cdf
png("data_output/evaluations/analysis/cdf-dist_member-events(1.148.224_pairs).png", width = 800, height = 700)
plot(Ecdf(~ dists$dist_km, scales=list(x=list(log=T)),
          q=c(.05, .1, .2, .5, .6, .7, .8, .9, .95, .99), 
          xlab = "Member-Event distance(in Km)", ylab = "Member-Events quantile"))
dev.off()
