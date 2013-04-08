# =============================================================================
#   recommender_functions.R - Recommendation algorithms functions
#   Copyright (C) 2013  Elias Paulino, Rodolfo Moraes and Augusto Queiroz
# 
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
  
  cat("  Reading the member.topics...\n")
  member.topics <- data.table(ReadAllCSVs("data_csv/", "member_topics"))
  setkey(member.topics, "member_id")
  member.topics <- subset(member.topics, member_id %in% unique(members$id))
  
  cat("  Reading the events...\n")
  events <- data.table(ReadAllCSVs(dir="data_csv/", obj_name="events")[,c("id", "created", "time", "venue_id", "group_id")])
  events <- rename(events, replace=c("id" = "event_id"))
  setkey(events, "venue_id")
  setkey(member.events, "event_id")
  events <- subset(events, id %in% unique(member.events$event_id))
  
  cat("  Reading the group.topics...\n")
  group.topics <- data.table(ReadAllCSVs("data_csv/", "group_topics"))
  setkey(group.topics, "group_id")
  group.topics <- subset(group.topics, group_id %in% events$group_id)
  
  cat("  Reading the venues...\n")
  venues <- data.table(read.csv("data_csv/venues.csv",sep = ",")[,c("id", "lat", "lon")])
  events <- rename(events, replace=c("id" = "venue_id"))
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
  # Now it is ordered by dist
  candidate.events.dist <- candidate.events.dist[order(dist, decreasing=F)]
  
  # We assume that the k.events will never be larger than all events.with.location
  return(candidate.events[1:k.events, event_id])
}

RecEvents.Popularity <- function(member.id, k.events, p.time){
  
  # ---------------------------------------------------------------------------
  # Distance Algorithm
  # ---------------------------------------------------------------------------
  member <- subset(members, id == member.id)
  
  candidate.events.dist <- subset(events.with.location, created <= p.time & time >= p.time)
  
  candidate.events.dist$dist <- geodDist(candidate.events.dist$lat, candidate.events.dist$lon, 
                                         member$lat, member$lon)
  # Now it is ordered by dist
  candidate.events.dist <- candidate.events.dist[order(dist, decreasing=F)]
  
  # ---------------------------------------------------------------------------
  # Popularity Algorithm (using only the events with distance <= 15 km )
  # ---------------------------------------------------------------------------
  candidate.events.pop <- subset(candidate.events.dist, dist <= 15)
  
  # Measure the candidate event's popularity until this moment (p.time < rsvp_time)
  count.events.pop <-  count(subset(member.events, 
                                    event_id %in% candidate.events.pop$event_id & rsvp_time < p.time), 
                             "event_id")
  
  candidate.events.pop <- merge(candidate.events.pop, count.events.pop, by = "event_id", all.x = T)
  
  if(nrow(candidate.events.pop) >= k.events){
    # Replace the NAs frequencies with 0
    set(candidate.events.pop, which(is.na(candidate.events.pop[["freq"]])),"freq", as.integer(0))
    
    # Sort the events by frequency!
    candidate.events.pop <- candidate.events.pop[order(freq, decreasing=T)]
    
    # Select the k most popular events
    events.result <- candidate.events.pop[1:k.events,]$event_id
    
  }else{
    # RANDOM choice from the candidate.events.dist (to recommend all k events)
    
    # Exclude from candidate.events.dist the candidate.events.pop event_id's (avoid id repetition)
    candidate.events.dist <- subset(candidate.events.dist, ! event_id %in% candidate.events.pop$event_id)
    
    # Select the random indexes from candidate.events.dist
    random.indexes <- sample(seq_len(nrow(candidate.events.dist)), k.events - nrow(candidate.events.pop))
    
    # Combine the selected candidate.events.pop ids with the random candidate.events.dist ids
    events.result <- c(candidate.events.pop$event_id, candidate.events.dist$event_id[random.indexes])
  }
  
  return(events.result)
}

RecEvents.Topic <- function(member.id, k.events, p.time){
  
  # ---------------------------------------------------------------------------
  # Distance Algorithm
  # ---------------------------------------------------------------------------
  member <- subset(members, id == member.id)
  
  candidate.events.dist <- subset(events.with.location, created <= p.time & time >= p.time)
  
  candidate.events.dist$dist <- geodDist(candidate.events.dist$lat, candidate.events.dist$lon, 
                                         member$lat, member$lon)
  # Now it is ordered by dist
  candidate.events.dist <- candidate.events.dist[order(dist, decreasing=F)]
  
  # ---------------------------------------------------------------------------
  # Topic Algorithm (using only the events with distance <= 15 km )
  # ---------------------------------------------------------------------------
  candidate.events.topic <- subset(candidate.events.dist, dist <= 15)
  
  # Select the topics of the member
  m.topics <- subset(member.topics, member_id == member$id)
  
  random.choice <- F
  
  if (nrow(candidate.events.topic) >= k.events){
    if(nrow(m.topics) > 0){
      
      # Select the groups with at least one topic of the member
      g.topics <- merge(m.topics, group.topics, by = "topic_id")
      g.topics$member_id <- NULL
      
      # Measure the intersection between the topics of a group and the topics of the member
      m.g.topics.intersection <- count(g.topics, "group_id")  
      # Measure the union between the topics of a group and the topics of the member
      m.g.topics.union <- count(group.topics, "group_id")  
      m.g.topics.union <- subset(m.g.topics.union, group_id %in% g.topics$group_id)
      m.g.topics.union$freq <- m.g.topics.union$freq + nrow(m.topics)
      m.g.topics.union$freq <- m.g.topics.union$freq - m.g.topics.intersection$freq
      # Finally, calculate the jaccard similarity between the sets
      m.g.jaccard <- m.g.topics.union
      m.g.jaccard$freq <- m.g.topics.intersection$freq / m.g.topics.union$freq
      
      # Select the candidate.events.topic that are in one of the groups of m.g.jaccard
      # That means, these events have at least one topic in common with the member
      candidate.events.topic <- merge(candidate.events.topic, m.g.jaccard, by = "group_id")
      
      if(nrow(candidate.events.topic) >= k.events){
        # Sort the events by frequency!
        candidate.events.topic <- candidate.events.topic[order(freq, decreasing=T)]
        
        # Select the k most popular events
        events.result <- candidate.events.topic[1:k.events,]$event_id
      }else{
        random.choice <- T
      }
    }else {
      # Partially RANDOM choice, the k.events are sampled from the candidate.events.topic
      events.result <- candidate.events.topic$event_id[sample(1:nrow(candidate.events.topic), 
                                                              k.events)]
    }
  }else{
    random.choice <- T
  }
  
  if(random.choice){
    # RANDOM choice from the candidate.events.dist to complete the k.events
    # All candidate.events.topic are added + the sampled events from candidate.events.dist
    
    # Exclude from candidate.events.dist the candidate.events.pop event_id's (avoid id repetition)
    candidate.events.dist <- subset(candidate.events.dist, ! event_id %in% candidate.events.topic$event_id)
    
    # Select the random indexes from candidate.events.dist
    random.indexes <- sample(seq_len(nrow(candidate.events.dist)), k.events - nrow(candidate.events.topic))
    
    # Combine the selected candidate.events.pop ids with the random candidate.events.dist ids
    events.result <- c(candidate.events.topic$event_id, candidate.events.dist$event_id[random.indexes])
  }
  
  return(events.result)
}

RecEvents.Weighted <- function(member.id, k.events, p.time){
  
  # ---------------------------------------------------------------------------
  # Distance Algorithm
  # ---------------------------------------------------------------------------
  member <- subset(members, id == member.id)
  
  candidate.events.dist <- subset(events.with.location, created <= p.time & time >= p.time)

  candidate.events.dist$dist <- geodDist(candidate.events.dist$lat, candidate.events.dist$lon, 
                                         member$lat, member$lon)

  # Remove the useless columns from candidate.events.dist
  candidate.events.dist$created <- NULL
  candidate.events.dist$time <- NULL
  candidate.events.dist$lat <- NULL
  candidate.events.dist$lon <- NULL
  
  # ---------------------------------------------------------------------------
  # Popularity Algorithm (using only the events with distance <= 15 km )
  # ---------------------------------------------------------------------------
  candidate.events.pop <- subset(candidate.events.dist, dist <= 15, event_id)
  
  # Measure the candidate event's popularity until this moment (p.time < rsvp_time)
  count.events.pop <-  count(subset(member.events, 
                                    event_id %in% candidate.events.pop$event_id & rsvp_time < p.time), 
                             "event_id")
  
  if(nrow(count.events.pop) > 0){
    # Select the candidate.events.pop with at least 1 rsvp
    candidate.events.pop <- merge(candidate.events.pop, count.events.pop, by = "event_id")
    # Rename freq to popularity
    candidate.events.pop <- rename(candidate.events.pop, replace = c("freq" = "popularity"))
  }else{
    if (nrow(candidate.events.pop) > 0){
      # Set NA in all popularities, this means that they have no popularity
      # This will be changed before the weighting phase
      candidate.events.pop$popularity <- NA
    }else{
      # Empty candidate.events.pop
      candidate.events.pop <- data.table(event_id = character(), popularity = numeric())
    }
  }
  
  # ---------------------------------------------------------------------------
  # Topic Algorithm (using only the events with distance <= 15 km )
  # ---------------------------------------------------------------------------
  candidate.events.topic <- subset(candidate.events.dist, dist <= 15, c(event_id, group_id))
  
  # Select the topics of the member
  m.topics <- subset(member.topics, member_id == member$id)
  
  if (nrow(candidate.events.topic) > 0){
    if(nrow(m.topics) > 0){
      
      # Select the groups with at least one topic of the member
      g.topics <- subset(group.topics, topic_id %in% m.topics$topic_id)

      ##### JACCARD SIMILARITY calculus #####
      # Measure the intersection between the topics of a group and the topics of the member
      m.g.topics.intersection <- count(g.topics, "group_id")  
      # Measure the union between the topics of a group and the topics of the member
      m.g.topics.union <- count(group.topics, "group_id")  
      m.g.topics.union <- subset(m.g.topics.union, group_id %in% g.topics$group_id)
      m.g.topics.union$freq <- m.g.topics.union$freq + nrow(m.topics)
      m.g.topics.union$freq <- m.g.topics.union$freq - m.g.topics.intersection$freq
      # Finally, calculate the jaccard similarity between the sets
      m.g.jaccard <- data.table(group_id = m.g.topics.union$group_id, 
                                topic_similarity = m.g.topics.intersection$freq / m.g.topics.union$freq)
      
      # Select the candidate.events.topic that are in one of the groups of m.g.jaccard
      # That means, these events have at least one topic in common with the member
      candidate.events.topic <- merge(candidate.events.topic, m.g.jaccard, by = "group_id")
      candidate.events.topic$group_id <- NULL
    }
    else {
      # Set NA in all similarities, this means that they have no similarity with the member
      # This will be changed before the weighting phase
      candidate.events.topic$topic_similarity <- NA
    }
  }else{
    # Empty candidate.events.topic
    candidate.events.topic <- data.table(event_id = character(), topic_similarity = numeric())
  }

  # ---------------------------------------------------------------------------
  # NORMALIZATION phase
  # ---------------------------------------------------------------------------
  
  # Normalize the DISTANCE based events
  max.dist <- max(candidate.events.dist$dist)
  min.dist <- min(candidate.events.dist$dist)
  candidate.events.dist$dist <- (candidate.events.dist$dist - min.dist)/(max.dist - min.dist)
  
  # Changing from distance to proximity
  candidate.events.dist$dist <- 1 - candidate.events.dist$dist
  
  # Rename it
  candidate.events.dist <- rename(candidate.events.dist, replace=c("dist" = "proximity"))
  
  # Normalize the POPULARITY based events
  
  if (nrow(candidate.events.pop) > 0){
    # Fake popularities creation
    if (sum(is.na(candidate.events.pop[["popularity"]])) > 0){
      candidate.events.pop$popularity <- runif(nrow(candidate.events.pop), 0, 1)
    }
    max.pop <- max(candidate.events.pop$popularity)
    min.pop <- min(candidate.events.pop$popularity)
    candidate.events.pop$popularity <- (candidate.events.pop$popularity - min.pop)/(max.pop - min.pop)
  }
  
  ## Normalize the TOPIC based events
  if (nrow(candidate.events.topic) > 0){
    # Fake popularities creation
    if (sum(is.na(candidate.events.topic[["topic_similarity"]])) > 0){
      candidate.events.topic$topic_similarity <- runif(nrow(candidate.events.topic), 0, 1)
    }
    max.topic <- max(candidate.events.topic$topic_similarity)
    min.topic <- min(candidate.events.topic$topic_similarity)
    candidate.events.topic$topic_similarity <- (candidate.events.topic$topic_similarity - min.topic)/(max.topic - min.topic)
  }
  
  # ---------------------------------------------------------------------------
  # Weighting phase
  # ---------------------------------------------------------------------------
  # Merge them all
  events.result <- merge(candidate.events.dist, candidate.events.pop, by = "event_id", all = T)
  events.result <- merge(events.result, candidate.events.topic, by = "event_id", all = T)
  
  # Apply the weights
  alfa <- 0.5
  beta <- 0.3

  # Set the NA values to 0 score (that means, the algorithms that dont know what 
  # to recommend should add nothing to the score)
  set(events.result, which(is.na(events.result[["proximity"]])), "proximity", 0)
  set(events.result, which(is.na(events.result[["popularity"]])), "popularity", 0)
  set(events.result, which(is.na(events.result[["topic_similarity"]])), "topic_similarity", 0)
  
  events.result$proximity <- (1 - alfa - beta) * events.result$proximity
  events.result$popularity <- alfa * events.result$popularity
  events.result$topic_similarity <- beta * events.result$topic_similarity
  
  # Calculate the final score (just summing them by row) 
  events.result$score <- rowSums(events.result[, 3:5, with = F], na.rm = T)
  
  # Sort decreasingly
  events.result <- events.result[order(events.result$score, decreasing = T)]
  
  # Select the k best events
  events.result <- events.result$event_id[1:k.events]
  
  return(events.result)
}
