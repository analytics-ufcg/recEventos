rm(list = ls())
source("src/rCode/common.R")

# Read the Member Events (already filtered)
print(noquote("Read the Member Events (already filtered)"))
member.events <- ReadAllCSVs(dir="data_output/partitions/", obj_name="member_events")
# Delete the event.time in the member.events
print(noquote("Delete the event.time in the member.events"))
member.events$event_time <- NULL


# Read and select the EVENTs
print(noquote("Read and select the events"))
events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[, c("id", "name", "time", "venue_id")]
events <- events[events$id %in% unique(member.events$event_id),]
colnames(events) <- c("event_id", "event_name", "event_time", "venue_id")


# Read and select the VENUEs
print(noquote("Read and select the events"))
venues <- read.csv("data_csv/venues.csv")[, c("id", "lat", "lon", "name", "city")]
venues <- venues[venues$id %in% unique(events$venue_id),]
colnames(venues) <- c("venue_id", "venue_lat", "venue_lon", "venue_name", "venue_city")


# Read and select the MEMBERs
print(noquote("Read and select the members"))
members <- ReadAllCSVs(dir="data_csv/", obj_name="members")[, c("id", "lat", "lon", "name", "city")]
members <- members[members$id %in% unique(member.events$member_id),]
colnames(members) <- c("member_id", "member_lat", "member_lon", "member_name", "member_city")

# ------------------------------------------------------------------------------
# Visualization Constraint: The member_city should always be in venues_city, but
# the opposite is not right because there are 1956 venues with other venue_city
# names (the most with writing errors, just a few with no place) and they contain
# 10591 real events! Therefore, the venues and its events can't be discarded. 
#
# Obs.: We are not going to discard the venues explicitly but the processment of 
# spliting the venues by city will not add them to cities. They are going to be 
# used only when the member events or its recommendations were shown.
# ------------------------------------------------------------------------------
cities.intersect <- intersect(members$member_city, venues$venue_city)

members <- members[members$member_city %in% cities.intersect,]

# ------------------------------------------------------------------------------
# Persist the data optimally to be used by the view
# EVENTS c("event_id", "event_name", "event_time", "venue_id", "venue_lat", "venue_lon")
# <CITY>/MEMBERs c("member_id", "member_lat", "member_lon", "member_name", "member_city", "all_event_ids")
# <CITY>/VENUEs c("venue_id", "venue_lat", "venue_lon", "venue_name", "venue_city", "all_event_ids")
# ------------------------------------------------------------------------------

# Selecting the Events of the Member and of the Venues

# Group member.events by member_id -> member_id, all_event_ids
print(noquote("Selecting the EVENTs of the MEMBERs..."))

member.all.events <- ddply(member.events[1:1000,], .(member_id), function(m.events){
  data.frame(all_event_ids = paste(m.events$event_id, collapse = ","))
}, .progress = "text")

# Merge members with this result
print(noquote("Merging the the EVENTs of the MEMBERs with the MEMBERs data..."))
members <- merge(members, member.all.events, by = "member_id")


# Group events by venue_id -> venue_id, all_event_ids
print(noquote("Selecting the EVENTs of the VENUEs..."))
venue.all.events <- ddply(events[1:1000,], .(venue_id), function(v.events){
  data.frame(all_event_ids = paste(v.events$event_id, collapse = ","))
}, .progress = "text")

# Merge venues with this result
print(noquote("Merging the the EVENTs of the VENUEs with the VENUEs data..."))
venues <- merge(venues, venue.all.events, by = "venue_id")

# -----------------------------------------------------------------------------
# PERSISTING ORGANIZED
# -----------------------------------------------------------------------------
print(noquote("Creating the directories..."))
dir.create("data_output/view", showWarnings=F)
view.dir <- "data_output/view/optimized/"
dir.create(view.dir, showWarnings=F)

# EVENTS
print(noquote("Persisting all EVENTs"))
write.csv(events, paste(view.dir, "events.csv", sep = ""), row.names = F)

# Split the Members per City (465 cities only) and Apply the function in it
print(noquote("Splitting by City and persisting the MEMBER and VENUEs..."))
thrash = ddply(members, .(member_city), function(m){
  city <- m$member_city[1]

  # Create the city directory
  dir.create(paste(view.dir, city, sep = ""), showWarnings=F)
  
  # Select the venues
  v <- venues[venues$venue_city %in% city,]

  # Persist the result
  write.csv(m, paste(view.dir, city, "/members.csv", sep = ""), row.names = F)
  write.csv(v, paste(view.dir, city, "/venues.csv", sep = ""), row.names = F)
}, .progress = "text")

