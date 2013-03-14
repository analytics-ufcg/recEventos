source("src/rCode/common.R")

venues <- read.csv("data_csv/venues.csv")[,c("id","lat","lon")]
venues.id <- data.frame(venue_id = venues[,"id"])

members <- ReadAllCSVs(dir="data_csv/", obj_name="members")[,c("id","lat","lon")]

events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[,c("id","venue_id","time")]
events = subset(events,!is.na(venue_id))

rsvps <- ReadAllCSVs(dir="data_csv/", obj_name="rsvps")[, c("member_id", "event_id", "response")]
rsvps <- rsvps[rsvps$response == "yes", c("member_id", "event_id")]

venue.events <- merge(venues.id,events,by.x = "venue_id",by.y = "venue_id")
