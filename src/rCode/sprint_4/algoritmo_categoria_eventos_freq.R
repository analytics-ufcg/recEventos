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
# Author: Elias Paulino
#
# File: algoritmo_categoria_eventos_freq.R
#   * Description: This script creates a function that recommends events based 
#                  of event's category.The priority of recomendation is ordened
#                  by popularity of event. 
#                   
#   * Inputs: -script: MEMBERs, MEMBER_TOPICS, GROUP_TOPICS, MEMBER_EVENTS(data_output),
#             VENUES, EVENTS csv data
#             -funtion: member id, k events to be recomended and time of event
#                       was created.
#   * Outputs: array with k events
# =============================================================================

# =============================================================================
# source() and library()
# =============================================================================
source("src/rCode/common.R")

# =============================================================================
# Executable script
# =============================================================================



CreateRecEnvironment <- function(){
  cat("Creating the Recommendation Environment...\n")
  
    
  cat("  Reading the members...\n")
  members <- ReadAllCSVs(dir="data_csv/", obj_name="members")[,c("id","city")]
  
  cat("Reading Members_Topics...")
  member.topics <- read.csv("data_csv/member_topics.csv",sep = ",")
  
  # -----------------------------------------------------------------------------
  # Read group_topics data csv
  # -----------------------------------------------------------------------------
  cat("Reading Group_Topics...")
  group.topics <- read.csv("data_csv/group_topics.csv",sep = ",")
  
  # -----------------------------------------------------------------------------
  # Read member_events(data_output/partitions/) data csv.
  # -----------------------------------------------------------------------------
  cat("Reading Members_Events...")
  member.events <- ReadAllCSVs(dir="data_output/partitions/", obj_name="member_events")
                    [,c("event_id","event_time")]
  
  # -----------------------------------------------------------------------------
  # Read venues data csv
  # -----------------------------------------------------------------------------
  cat("Reading Venues...")
  venues <- read.csv("data_csv/venues.csv",sep = ",")[,c("id","city")]
  
  # -----------------------------------------------------------------------------
  # Read events data csv and filt events that hasn't venue
  # -----------------------------------------------------------------------------
  cat("Reading Events...")
  all.events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[,c("id","venue_id","group_id", "created", "time")]
  cat("Filting Events...")
  all.events <- subset(all.events, all.events$id %in% member.events$event_id)
  
  # -----------------------------------------------------------------------------
  # merge member.events and all.events.This is necessery for insert venue id at
  # table
  # -----------------------------------------------------------------------------
  cat("Merging member.events and all.events...")
  event.venue <- merge(member.events,all.events,by.x = "event_id",by.y = "id")
  
  # -----------------------------------------------------------------------------
  # merge event.venue and venues.This is necessery for insert venue name at table
  # -----------------------------------------------------------------------------
  cat("Merging event.venues and venues...")
  merge.final <- merge(event.venue,venues,by.x = "venue_id" , by.y = "id")  
  
  environment()
}


RecEvents.Topic <- function(member.id,k.events,p.time){
  
  # -----------------------------------------------------------------------------
  # filt members by city of given user
  # -----------------------------------------------------------------------------
  cat("Filting members per city...")
  cit <- as.character(subset(members,id == member.id)[,c("city")])
  
  # -----------------------------------------------------------------------------
  # take topics of given user
  # -----------------------------------------------------------------------------
  cat("Filting members.topics per user...")
  user.topics <- subset(member.topics,member_id == member.id)
  
  # -----------------------------------------------------------------------------
  # take all groups of topics of user
  # -----------------------------------------------------------------------------
  cat("Merging user.topics and group.topics...")
  groups.topics <- merge(user.topics,group.topics,by.x = "topic_id",by.y = "topic_id")[,c("group_id","topic_id")]
  
  # -----------------------------------------------------------------------------
  # filt merge.final by user city
  # -----------------------------------------------------------------------------
  cat("Filting merge.final per city and p.time...")
  merge.final.filt.per.city <- subset(merge.final,city == cit & event_time > p.time)
  events.groups <- merge(merge.final.filt.per.city,groups.topics,by.x = "group_id", by.y="group_id")[,c("event_id")]
  events <- count(as.data.frame(events.groups))
  events.recomended <- as.character(events[ order(-events[,c("events.groups")], events[,c("freq")], decreasing = TRUE), ][1:k.events,1])
  
  
}


