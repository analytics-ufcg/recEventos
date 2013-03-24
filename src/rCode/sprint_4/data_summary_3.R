rm(list = ls())
source("src/rCode/common.R")

filename <- "data_output/evaluations/analysis/member_events_dists.csv"

if (!file.exists(filename)){
  
  print(noquote("Read the Member Events (already filtered)"))
  member.events <- data.table(ReadAllCSVs(dir="data_output/partitions/", obj_name="member_events"))
  setkey(member.events, "member_id")
  
  print(noquote("Reading the members..."))
  members <- data.table(ReadAllCSVs(dir="data_csv/", obj_name="members")[,c("id","lat","lon")])
  setkey(members, "id")
  
  print(noquote("Reading the events..."))
  events <- data.table(ReadAllCSVs(dir="data_csv/", obj_name="events")[,c("id","time","venue_id")])
  setkey(events, "venue_id")
  
  print(noquote("Reading the venues..."))
  venues <- data.table(read.csv("data_csv/venues.csv",sep = ",")[,c("id", "lat", "lon")])
  setkey(venues, "id")
  
  print(noquote("Filtering the events with location..."))
  events.with.location = events[venues]
  events.with.location$id <- as.character(events.with.location$id)
  setkey(events.with.location, "id")
  
  rm(events, venues)
  
  member.ids <- sort(unique(member.events$member_id))
  
  dists <- foreach(m = member.ids, .combine = rbind) %do% {
    member <- subset(members, id == m)
    
    my.events.ids <- as.character(subset(member.events, member_id == m)$event_id)
    my.events <- events.with.location[my.events.ids]
    dists <- deg.dist(member$lon, member$lat, my.events$lon, my.events$lat)
    
    data.frame(member=rep(m, length(dists)), event_id = my.events.ids, dist_km = dists)
  }
  
  write.csv(dists, file = filename)
}else{
  dists <- read.csv(file = filename)  
}

# PLOT a cdf
png("data_output/evaluations/analysis/cdf-dist_member-events(1.148.224_pairs).png", width = 800, height = 700)
plot(Ecdf(~ dists$dist_km, scales=list(x=list(log=T)),
          q=c(.05, .1, .2, .5, .6, .7, .8, .9, .95, .99), main = "", 
          xlab = "Member-Event distance(in Km)", ylab = "Member-Events quantile"))
dev.off()
