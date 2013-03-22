source("src/rCode/common.R")

members <- ReadAllCSVs(dir="data_csv/", obj_name="members")
member.topics <- read.csv("data_csv/member_topics.csv",sep = ",")
group.topics <- read.csv("data_csv/group_topics.csv",sep = ",")
group.events <- read.csv("data_csv/group_events.csv",sep = ",")
events1 <- ReadAllCSVs(dir="data_csv/", obj_name="events")
events1 <- subset(events1, !is.na(venue_id))
venues <- read.csv("data_csv/venues.csv",sep = ",")[,c("id","city")]


rsvps <- ReadAllCSVs(dir="data_csv/", obj_name="rsvps")[, c("member_id", "event_id", "response")]
rsvps <- rsvps[rsvps$response == "yes", c("event_id")]

recomedation <- function(userId,cit,kRec){
  user.topics <- subset(member.topics,member_id == userId)
  groups.topics <- merge(user.topics,group.topics,by.x = "topic_id",by.y = "topic_id")
  events.groups <- merge(groups.topics,events1,by.x = "group_id",by.y="group_id")[,c("id","venue_id")]
  events <- merge(events.groups,rsvps,by.x = "id",by.y="event_id")
  events.with.venue.city <- merge(events,venues,by.x = "venue_id",by.y = "id")
  events <- count(events.with.venue.city)
  events.recomended <- subset(events,city == cit)
  
}