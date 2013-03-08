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
# File: dist_user_event.R
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

require("fossil")

# =============================================================================
# Inputs
# =============================================================================

print(noquote("Reading the members..."))
members = ReadAllCSVs(dir="data_csv/", obj_name="members")[,c("id","lat","lon")]

print(noquote("Reading the events..."))
events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[,c("id","time","venue_id")]

print(noquote("Reading the venues..."))
venues <- read.csv("data_csv/venues.csv",sep = ",")[,c("id", "lat", "lon")]

print(noquote("Filtering the events with location..."))
events.with.location = merge(events, data.frame(id = venues[,"id"]), 
                             by.x = "venue_id", 
                             by.y = "id")
events.with.location$id <- as.character(events.with.location$id)

# =============================================================================
# Function definitions
# =============================================================================

# ----------------------------------------------------------------------------
# Return k lagest distance between reciver user and all events.
# ----------------------------------------------------------------------------

KNearestEvents <- function(memberId, kEvents, p.time){
  
  member <- subset(members, id == memberId) 

  venue.distance <- deg.dist(member$lon, member$lat, venues$lon, venues$lat)
  venue.distance = cbind(venues$id, as.data.frame(venue.distance))
  colnames(venue.distance) = c("venue_id","dist")
  venue.distance = venue.distance[order(venue.distance$dist, decreasing = FALSE), ]

  events.dist <- merge(subset(events.with.location, time >= p.time), 
                       venue.distance, 
                       by= "venue_id")
  events.dist <- events.dist[order(events.dist$dist, decreasing = FALSE), ]
  
  return (events.dist[1:kEvents, "id"])
}


