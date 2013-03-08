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
# Function definitions
# =============================================================================

venues <- read.csv("data_csv/venues.csv",sep = ",")

# ----------------------------------------------------------------------------
# Return k lagest distance between reciver user and all events.
# ----------------------------------------------------------------------------

k.nearest.events <- function(userLon, userLat, kEvents){
  
  distance <- deg.dist(userLon,userLat,venues$lon,venues$lat)
  venue.distance = cbind(venues$id, as.data.frame(distance))
  colnames(venue.distance) = c("venueId","dist")
  venue.distance = venue.distance[order(venue.distance$dist, decreasing = FALSE), ]
  events.dist <- merge(events.with.location, venue.distance[1:kEvents,], 
             by.x="venue_id", by.y = "venueId", all.y = T)
  events.dist.order = events.dist[order(events.dist$dist, decreasing = FALSE), ]
    
  return (events.dist.order[1:kEvents,c(2)])
}

# ----------------------------------------------------------------------------
# Return k lagest distance between all user reciver and all events.
# ----------------------------------------------------------------------------

recomedation <- function(tableUsers,kEvents){
  all.recomendations = data.frame()
  
  for(i in 1:dim(tableUsers)[1]){
    events.recomended = k.nearest.events(tableUsers$lon[i],tableUsers$lat[i],kEvents)
    events.recomended =  cbind(events.recomended,user_id = c(1:dim(events.recomended)[1]))
    events.recomended$user_id = tableUsers$id[i]
    all.recomendations = rbind(all.recomendations,events.recomended)
  }
  return(all.recomendations)
}
