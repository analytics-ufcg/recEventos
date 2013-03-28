source("src/rCode/common.R")

members <- ReadAllCSVs(dir="data_csv/", obj_name="members")[,c("id","city")]
member.topics <- read.csv("data_csv/member_topics.csv",sep = ",")
group.topics <- read.csv("data_csv/group_topics.csv",sep = ",")

member.events <- read.csv("data_output/partitions/member_events_1.csv")

venues <- read.csv("data_csv/venues.csv",sep = ",")[,c("id","city")]

events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[,c("id","venue_id","group_id", "created", "time")]
events <- subset(events, events$id %in% member.events$event_id)

merge.final <- merge(events,venues,by.x = "venue_id" , by.y = "id")
# merge.final <- merge(even, event.venue.with.city, by.x = "event_id", by.y = "id")




recomedation <- function(member.id,k.events,p.time){
  cit <- as.character(subset(members,id == member.id)[,c("city")])
  #filtra taleba user.topics para o usuario passado(pega todos os topicos do usuario)
  user.topics <- subset(member.topics,member_id == member.id)
  #pega todos os grupos de topicos do usuario
  groups.topics <- merge(user.topics,group.topics,by.x = "topic_id",by.y = "topic_id")[,c("group_id","topic_id")]
  #pega todos os eventos dos grupos do topico anterior
  count.groups <- count(groups.topics,"group_id")
  merge.final.filt.per.city <- subset(merge.final,city == cit & event_time > p.time)
  
  events.groups <- merge(count.groups,merge.final.filt.per.city,by.x = "group_id", by.y="group_id")
  
  
  
  events <- count(as.data.frame(events.groups))
  
  events.recomended <- as.character(events[ order(-events[,c("events.groups")], events[,c("freq")], decreasing = TRUE), ][1:k.events,1])
  
  
}