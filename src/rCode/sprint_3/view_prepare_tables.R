rm(list = ls())
source("src/rCode/common.R")

# Read the Member Events (already filtered)
print(noquote("Read the Member Events (already filtered)"))
member.events <- ReadAllCSVs(dir="data_output/partitions/", obj_name="member_events")

# Read and select the members
print(noquote("Read and select the members"))
members <- ReadAllCSVs(dir="data_csv/", obj_name="members")[, c("id", "lat", "lon", "name")]
members <- members[members$id %in% unique(member.events$member_id),]

# Read and select the events
print(noquote("Read and select the events"))
events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[, c("id", "name", "venue_id", "time")]
events <- events[events$id %in% unique(member.events$event_id),]

# Read and select the venues
print(noquote("Read and select the events"))
venues <- read.csv("data_csv/venues.csv")[, c("id", "lat", "lon", "name", "city")]
venues <- venues[venues$id %in% unique(events$venue_id),]

# Delete the event.time in the member.events
print(noquote("Delete the event.time in the member.events"))
member.events$event_time <- NULL

# Persist in data_view
print(noquote("Persist the data"))
dir.create("data_output/view/", showWarnings=F)
write.csv(members,"data_output/view/members.csv", row.names = F)
write.csv(events,"data_output/view/events.csv", row.names = F)
write.csv(venues,"data_output/view/venues.csv", row.names = F)
write.csv(member.events,"data_output/view/member_events.csv", row.names = F)