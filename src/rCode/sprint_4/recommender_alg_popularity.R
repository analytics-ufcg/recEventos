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
# Author: Rodolfo Moraes Martins
#
# File: recommender_alg_popularity.R
#
#   * Description: This file have two functions, k.nearest.events and recomendation.                     
#
#   * Inputs: Venues' table, events with location table, members' table
#
#   * Outputs: List of k events recomeded for users gived.The recomendation is made
#              according of distance between user's geo-location and event's geo-location
#
# =============================================================================

# =============================================================================
# source() and library()
# =============================================================================
source("src/rCode/common.R")

# =============================================================================
# Inputs
# =============================================================================

print(noquote("Reading the members..."))
member_events <- ReadAllCSVs(dir="data_output/partitions/", obj_name="member_events")
setkey(members, "id")

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
events.with.location$lat <- NULL
events.with.location$lon <- NULL
events.with.location$id <- as.character(events.with.location$id)
setkey(events.with.location, "time")

rm(events)

# =============================================================================
# Function definitions
# =============================================================================

# ----------------------------------------------------------------------------
# Return k lagest distance between receiver user and all events.
# ----------------------------------------------------------------------------

MostPopularEvents <- function(event.id, k.events, p.time){
  count.var <- count(member_events, "event_id")
  count.var <- count.var[order(count.var$freq, decreasing = T),]
  return(count.var)
}

MostClosePopularEvents <- function(member.id, k.events, p.time){
  
  member <- subset(members, id == member.id)
  
  venue.distance <- data.table(venue_id = venues$id, 
                               dist = deg.dist(member$lon, member$lat, venues$lon, venues$lat))
  setkey(venue.distance, "dist")  # Now it is ordered by dist
  
  events.dist <- merge(subset(events.with.location, time >= p.time), 
                       venue.distance, 
                       by= "venue_id")
  setkey(events.dist, "dist")  # Now it is ordered by dist
  
  events.dist.recommended <- events.dist[1:100]
  
  count.events <- count(member_events, "event_id")
  
  count.events <- data.table(count.events[order(count.events$freq, decreasing = T),])
  
  merge.tables <- merge(count.events, events.dist.recommended, by.x="event_id", by.y="id")
  
  merge.tables <- merge.tables[order(merge.tables$freq, decreasing = T),]
  
  merge.tables[1:10,]
  
}
