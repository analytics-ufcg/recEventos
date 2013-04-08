# =============================================================================
#   data_partitioning.R - Partition the events of a member in train and test
#   Copyright (C) 2013  Augusto Queiroz
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
#
# * Goal:
# * Inputs
# * Outputs:
# =============================================================================

rm(list = ls())

# =============================================================================
# source() and library()
# =============================================================================
source("src/rCode/common.R")

# =============================================================================
# Function definition
# =============================================================================
CreateMemberEvents <- function(min.events.per.member, max.members.per.file){
  cat("Reading the MEMBER.EVENTs (if there is any)...\n")
  member.events <- ReadAllCSVs(dir="data_output/partitions/", obj_name="member_events")
  
  if (is.null(member.events)){
    cat("Creating the MEMBER.EVENTs (no there isn't)...\n")
    cat("    Reading the EVENTs...\n")
    events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[, c("id", "created", "time", "venue_id")]
    
    cat("    Reading the VENUEs...\n")
    venues <- read.csv("data_csv/venues.csv")
    
    cat("    Selecting the VENUEs with valid location (diff from (0,0))...\n")
    venues <- venues[!(venues$lon == 0 & venues$lat == 0),]

    cat("    Selecting the EVENTs with valid locations...\n")
    events <- events[(!is.na(events$venue_id) & events$venue_id %in% venues$id), c("id")]
    
    cat("    Reading the RSVPs...\n")
    rsvps <- ReadAllCSVs(dir="data_csv/", obj_name="rsvps")[, c("member_id", "event_id", "mtime", "response")]
    
    cat("    Selecting the RSVPs with response equals yes...\n")
    rsvps <- rsvps[rsvps$response == "yes", c("member_id", "event_id", "mtime")]
    
    cat("    Selecting the RSVPs with valid EVENTs\n")
    member.events <- subset(rsvps, event_id %in% events)
    
    cat("    Selecting the members with at least", min.events.per.member, "complete event(s)...\n")
    member.count <- count(member.events, "member_id")
    member.count <- member.count[member.count$freq >= min.events.per.member,]
    member.events <- member.events[member.events$member_id %in% member.count$member_id,]
    
    rm(venues, events, rsvps, member.count)

    # Reorganizing the data.frame
    colnames(member.events) <- c("member_id", "event_id", "rsvp_time")
    
    cat("    Persisting the member.events...\n")
    members <- unique(member.events$member_id)
    data.divisions <- ceil(length(members)/max.members.per.file)
    index.divisions <- as.integer(quantile(0:length(members), seq(0, 1, 1/data.divisions)))
    
    cat("    Persisting the member_events data in csv files...\n")
    for (i in 1:data.divisions){
      cat("member_events part: ", i, "/", data.divisions, "\n", sep = "")
      write.csv(subset(member.events, member_id %in% members[(index.divisions[i]+1) : index.divisions[i+1]]), 
                file = paste("data_output/partitions/member_events_",i,".csv", sep = ""), 
                row.names = F)
    }
  }
  
  return (member.events)
}

PartitionEvents <- function(df, partition.num){
  df.melt <- melt(df, id.vars=c("member_id", "event_id"))
  
  # Order the events creation and execution (do the magic!)
  df.melt <- df.melt[order(df.melt$value),]

  # Give weights to the actions (1 to event_created and -1 to event_time), 
  # then run a cummulative sum over the weights and the result is the vector of 
  # the max intersection between events!!!!!! (This was intelligent! =D)
  action.weights <- rep(1, nrow(df.melt))
  action.weights[df.melt$variable == "event_time"] <- -1
  sizes <- cumsum(action.weights)
  
  # Select the PARTITION.TIME 
  # The events intersection size is ordered (decreasing = T) 
  # For each partition.time (there are at most 2 * min.events.per.member)
  #     Select the action (always an event creation) with the max intersection between the remaining ones
  #     Select randomly a partition.time between this action and the next one
  
  p.times <- NULL
  for (j in order(sizes, decreasing=T)[1:partition.num]){
    actions <- df.melt[j:(j+1),"value"]/1000
    p.times <- c(p.times, sample((actions[1] + 1):(actions[2] - 1), 1) * 1000)
  }
  
  return(data.frame(partition = 1:partition.num, partition_time = p.times,
                    max_intersect_events = max(sizes), events_num = nrow(df)))
}


# =============================================================================
# Executable Script
# =============================================================================

min.events.per.member <- 5
max.members.per.file <- 15000 # "Empirically" selected
partition.num <- 1

# Create output dirs
dir.create("data_output/", showWarnings=F)
dir.create("data_output/partitions/", showWarnings=F)

# Read/Create the MemberEvents
member.events <- CreateMemberEvents(min.events.per.member, max.members.per.file)

# Remove the rsvp_time
member.events$rsvp_time <- NULL

# Read the events and merge to get the creation and time
events <- ReadAllCSVs("data_csv/", "events")[,c("id", "created", "time")]
colnames(events) <- c("event_id", "event_created", "event_time")
member.events <- merge(member.events, events, by = "event_id")
rm(events)

cat("Partitioning the member's events (", partition.num, " partition(s))...\n", sep = "")
members <- unique(member.events$member_id)
data.divisions <- ceil(length(members)/max.members.per.file)
index.divisions <- as.integer(quantile(0:length(members), seq(0, 1, 1/data.divisions)))

for (i in 1:data.divisions){
  
  cat("Data Division ", i, "/", data.divisions, "\n", sep = "")
  
  system.time(partitioned.data <- ddply(subset(member.events, 
                                               member_id %in% members[(index.divisions[i]+1) : index.divisions[i+1]]), 
                                        .(member_id), PartitionEvents, partition.num, 
                                        .parallel=F, .progress="text"))
  
  cat("Persisting the partitions in a csv file...\n")
  write.csv(partitioned.data, 
            file = paste("data_output/partitions/member_partitions_", i, ".csv", sep = ""), 
            row.names = F)
  
  cat("\n")
}
