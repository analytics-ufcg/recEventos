# =============================================================================
# Copyright (C) 2013 Augusto Queiroz, Elias Paulino, Rodolfo Moraes, 
#                    Ricardo Araujo e Leandro Balby
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal 
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#     
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
# SOFTWARE.
#
# Author: Augusto Queiroz
#
# File: 
#   * Description: 
#   * Inputs: 
#   * Outputs: 
# =============================================================================

# =============================================================================
# source() and library()
# =============================================================================
source("src/rCode/common.R")

# =============================================================================
# Executable script
# =============================================================================


members <- ReadAllCSVs(dir="data_csv/", obj_name="members")[,c("id","city")]
member.topics <- read.csv("data_csv/member_topics.csv",sep = ",")
group.topics <- read.csv("data_csv/group_topics.csv",sep = ",")
member.events <- count(ReadAllCSVs(dir="data_output/partitions/", obj_name="member_events"))[,c("event_id","event_time")]
venues <- read.csv("data_csv/venues.csv",sep = ",")[,c("id","city")]
all.events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[,c("id","venue_id","group_id", "created", "time")]
all.events <- subset(all.events, all.events$id %in% member.events$event_id)
event.venue <- merge(member.events,all.events,by.x = "event_id",by.y = "id")
merge.final <- merge(event.venue,venues,by.x = "venue_id" , by.y = "id")




recomedation2 <- function(member.id,k.events,p.time){
  
  cit <- as.character(subset(members,id == member.id)[,c("city")])
  user.topics <- subset(member.topics,member_id == member.id)
  groups.topics <- merge(user.topics,group.topics,by.x = "topic_id",by.y = "topic_id")[,c("group_id","topic_id")]
  count.groups <- count(groups.topics,"group_id")
  merge.final.filt.per.city <- subset(merge.final,city == cit & event_time > p.time)
  events.groups <- merge(merge.final.filt.per.city,count.groups,by.x = "group_id", by.y="group_id")[,c("event_id","freq")]
  events.recomended <- as.character(events.groups[ order(-events.groups[,c("event_id")], events.groups[,c("freq")], decreasing = TRUE), ][1:k.events,1])
  
  
}