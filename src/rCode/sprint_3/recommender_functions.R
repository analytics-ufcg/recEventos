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
# Function definitions
# =============================================================================

CreateRecEnvironment <- function(){
  cat("Creating the Recommendation Environment...\n")
  
  cat("  Reading the member.events...\n")
  member.events <- data.table(ReadAllCSVs("data_output/partitions/", "member_events"))
  
  cat("  Reading the members...\n")
  members <- data.table(ReadAllCSVs(dir="data_csv/", obj_name="members")[,c("id","lat","lon")])
  setkey(members, "id")
  setkey(member.events, "member_id")
  members <- subset(members, id %in% unique(member.events$member_id))
  
  cat("  Reading the events...\n")
  events <- data.table(ReadAllCSVs(dir="data_csv/", obj_name="events")[,c("id", "created", "time", "venue_id")])
  setkey(events, "venue_id")
  setkey(member.events, "event_id")
  events <- subset(events, id %in% unique(member.events$event_id))
  
  cat("  Reading the venues...\n")
  venues <- data.table(read.csv("data_csv/venues.csv",sep = ",")[,c("id", "lat", "lon")])
  setnames(venues, old=1, new="venue_id")
  setkey(venues, "venue_id")
  
  cat("  Filtering the events with location...\n")
  events.with.location <- merge(events, venues)
  events.with.location$venue_id <- NULL
  events.with.location$id <- as.character(events.with.location$id)
  
  # Just to order and make the subset in the distance algorithm faster
  setkey(events.with.location, "created")
  
  rm(member.events, venues, events)
  
  environment()
}

RecEvents.Distance <- function(member.id, k.events, p.time){
  
  member <- subset(members, id == member.id)

  candidate.events <- subset(events.with.location, created <= p.time & time >= p.time)
  
  candidate.events$dist <- geodDist(candidate.events$lat, candidate.events$lon, 
                                    member$lat, member$lon)
  setkey(candidate.events, "dist")  # Now it is ordered by dist

  return(candidate.events[1:min(k.events, nrow(candidate.events)), id])
}