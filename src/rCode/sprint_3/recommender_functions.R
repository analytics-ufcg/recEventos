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
# Author: Elias Paulino, Augusto Queiroz and Rodolfo Moraes
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
  
  rm(venues, events)
  
  environment()
}

RecEvents.Distance <- function(member.id, k.events, p.time){
  
  member <- subset(members, id == member.id)

  candidate.events <- subset(events.with.location, created <= p.time & time >= p.time)
  
  candidate.events$dist <- geodDist(candidate.events$lat, candidate.events$lon, 
                                    member$lat, member$lon)
  setkey(candidate.events, "dist")  # Now it is ordered by dist

  # We assume that the k.events will never be larger than all events.with.location
  return(candidate.events[1:k.events, id])
}

RecEvents.Popularity <- function(member.id, k.events, p.time){
  
  # ---------------------------------------------------------------------------
  # Distance Algorithm
  # ---------------------------------------------------------------------------
  member <- subset(members, id == member.id)
  
  candidate.events.dist <- subset(events.with.location, created <= p.time & time >= p.time)
  
  candidate.events.dist$dist <- geodDist(candidate.events.dist$lat, candidate.events.dist$lon, 
                                    member$lat, member$lon)
  setkey(candidate.events.dist, "dist")  # Now it is ordered by dist
  
  # ---------------------------------------------------------------------------
  # Popularity Algorithm (using only the events with distance <= 15 km )
  # ---------------------------------------------------------------------------
  candidate.events.pop <- subset(candidate.events.dist, dist <= 15)
  candidate.events.pop <- rename(candidate.events.pop, replace=c("id" = "event_id"))
  
  # Measure the candidate event's popularity until this moment (p.time < rsvp_time)
  count.events.pop <-  count(subset(member.events, 
                                 event_id %in% candidate.events.pop$id & rsvp_time < p.time), 
                          "event_id")
  
  candidate.events.pop <- merge(candidate.events.pop, count.events.pop, by = "event_id", all.x = T)
  
  if(nrow(candidate.events.pop) >= k.events){
    # Replace the NAs frequencies with 0
    set(candidate.events.pop, which(is.na(candidate.events.pop[["freq"]])),"freq", as.integer(0))
    
    # Sort the events by frequency!
    setkey(candidate.events.pop, "freq")
    
    # Select the k most popular events
    events.result <- candidate.events.pop[1:k.events,]$event_id
    
  }else{
    # RANDOM choice from the candidate.events.dist (to recommend all k events)
    events.result <- c(candidate.events.pop$event_id, 
                       candidate.events.dist$id[sample(1:nrow(candidate.events.dist), 
                                                       k.events - nrow(candidate.events.pop))])
  }

  return(events.result)
}