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
# Author: Elias Paulino and Augusto Queiroz
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
source("src/rCode/common.R")

# =============================================================================
# Inputs
# =============================================================================

SetEnvironment.Distance <- function(){
  cat("Setting Environment: Distance...")
  
  cat("  Reading the members...")
  members <- data.table(ReadAllCSVs(dir="data_csv/", obj_name="members")[,c("id","lat","lon")])
  setkey(members, "id")
  
  cat("  Reading the events...")
  events <- data.table(ReadAllCSVs(dir="data_csv/", obj_name="events")[,c("id","time","venue_id")])
  setkey(events, "venue_id")
  
  cat("  Reading the venues...")
  venues <- data.table(read.csv("data_csv/venues.csv",sep = ",")[,c("id", "lat", "lon")])
  setkey(venues, "id")
  
  cat("  Filtering the events with location...")
  events.with.location <- events[venues]
  events.with.location$lat <- NULL
  events.with.location$lon <- NULL
  events.with.location$id <- as.character(events.with.location$id)
  setkey(events.with.location, "time")
  
  rm(events)
  
  cat("  Sharing Environment with RecEvents.Distance...")
  # Share Environment is the same as: This function environment will be the 
  # environment of the RecEvents.Distance function (this is different from its 
  # evaluation environment, created during its evaluation)
  # The special assignment operator (<<-) is used to force the assignment occur 
  # in the RecEvents.Distance actual environment, not as a temp variable in this 
  # evaluation environment
  environment(RecEvents.Distance) <<- environment() 
}

# =============================================================================
# Function definitions
# =============================================================================

# ----------------------------------------------------------------------------
# Return k lagest distance between receiver user and all events.
# ----------------------------------------------------------------------------

RecEvents.Distance <- function(member.id, k.events, p.time){
  
  member <- subset(members, id == member.id)

  venue.distance <- data.table(venue_id = venues$id, 
                               dist = deg.dist(member$lon, member$lat, venues$lon, venues$lat))
  setkey(venue.distance, "dist")  # Now it is ordered by dist

  events.dist <- merge(subset(events.with.location, time >= p.time), 
                       venue.distance, 
                       by= "venue_id")
  setkey(events.dist, "dist")  # Now it is ordered by dist
  
  return(events.dist[1:min(k.events, nrow(events.dist)), id])
}