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
# =============================================================================
#
# Author: Augusto Queiroz
#
# File: partition_data.R
#   * Description: This file partition the events of a member chronologically 
#                  in 10 sequential data splits of train/test. 
#   * Inputs: the data_csv directory containing the events and  rsvps csv files
#   * Outputs: the data_output directory with the member_event_partitions.csv file 
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
  cat("Reading the MEMBER.EVENTs (if there is any)...")
  member.events <- ReadAllCSVs(dir="data_output/partitions/", obj_name="member_events")
  
  if (is.null(member.events)){
    cat("Creating the MEMBER.EVENTs (no there isn't)...")
    cat("    Reading the EVENTs...")
    events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[, c("id", "created", "time", "venue_id")]
    
    cat("    Reading the VENUEs...")
    venues <- read.csv("data_csv/venues.csv")
    
    cat("    Selecting the VENUEs with valid location (diff from (0,0))...")
    venues <- venues[!(venues$lon == 0 & venues$lat == 0),]
    
    cat("    Selecting the EVENTs with valid locations...")
    events <- events[(!is.na(events$venue_id) & events$venue_id %in% venues$id), c("id", "created", "time")]
    
    cat("    Reading the RSVPs...")
    rsvps <- ReadAllCSVs(dir="data_csv/", obj_name="rsvps")[, c("member_id", "event_id", "response")]
    
    cat("    Selecting the RSVPs with response equals yes...")
    rsvps <- rsvps[rsvps$response == "yes", c("member_id", "event_id")]
    
    cat("    Merging the RSVPs with EVENTs table (to add the EVENTs <time>)")
    member.events <- merge(rsvps, events, 
                           by.x = "event_id", by.y = "id")
    
    cat("    Selecting the members with at least", min.events.per.member, "event(s)...")
    member.count <- count(member.events, "member_id")
    member.count <- member.count[member.count$freq >= min.events.per.member,]
    member.events <- member.events[member.events$member_id %in% member.count$member_id,]
    
    rm(rsvps, events, member.count)

    # Reorganizing the data.frame
    member.events <- member.events[,c("member_id", "event_id", "created", "time")]
    colnames(member.events) <- c("member_id", "event_id", "event_created", "event_time")
    
    cat("    Persisting the member.events...")
    members <- unique(member.events$member_id)
    data.divisions <- ceil(length(members)/max.members.per.file)
    index.divisions <- as.integer(quantile(0:length(members), seq(0, 1, 1/(data.divisions + 1))))
    
    cat("    Persisting the member_events data in csv files...")
    for (i in 1:data.divisions){
      cat("Data Division ", i, "/", data.divisions, sep = "")
      write.csv(subset(member.events, member_id %in% members[(index.divisions[i]+1) : index.divisions[i+1]]), 
                file = paste("data_output/partitions/member_events_",i,".csv", sep = ""), 
                row.names = F)
    }
  }
  
  return (member.events)
}

PartitionEvents <- function(df, partition.num){
  
  a <- melt(df, id.vars=c("member_id", "event_id"))
  
  # Lead with two exceptional cases: not created OR not executed events (and repeated)
  a.count <- count(a, "event_id")
  a <- subset(a, a$event_id %in% as.character(subset(a.count, freq %% 2 == 0)$event_id))
  
  # Do the magic!
  a <- a[order(a$value),]
  
  result <- list()
  sizes <- NULL
  
  for (i in 1:nrow(a)){
    if (a[i,"variable"] == "event_created"){
      if (i <= 1){
        result[[i]] <- a[i,"event_id"]
      }else{
        result[[i]] <- c(result[[i-1]], a[i,"event_id"])
      }
    }else{
      result[[i]] <- subset(result[[i-1]], result[[i-1]] != a[i,"event_id"])
    }
    sizes <- c(sizes, length(result[[i]]))
  }
  
  p.times <- NULL
  for (j in order(sizes, decreasing=T)[1:partition.num]){
    b <- a[j:(j+1),"value"]/1000
    p.times <- c(p.times, sample(b[1]:b[2], 1))
  }
  
  #   cat(p.times)
  
  return(data.frame(partition = 1:partition.num, partition_time = p.times))
}


# =============================================================================
# Executable Script
# =============================================================================

# TODO(Augsto): fazer algoritmo get_best_partition (que calcula o max_intersect_events)
# Rodar particionamento 
# Analisar o tamanho dos testes: plotar o max intersect events por user

# -----------------------------------------------------------------------------
# DATA PARTITIONS CREATION                         
# -----------------------------------------------------------------------------

min.events.per.member <- 5
max.members.per.file <- 15000 # "Empirically" selected
partition.num <- 1

# Create output dirs
dir.create("data_output/", showWarnings=F)
dir.create("data_output/partitions/", showWarnings=F)

# Read/Create the MemberEvents
member.events <- CreateMemberEvents(min.events.per.member, max.members.per.file)

members <- unique(member.events$member_id)
data.divisions <- ceil(length(members)/max.members.per.file)
index.divisions <- as.integer(quantile(0:length(members), seq(0, 1, 1/(data.divisions + 1))))

cat("    Partitioning the member's events (", partition.num, " partition(s))...", sep = "")

for (i in 1:data.divisions){
  
  cat("Data Division ", i, "/", data.divisions, sep = "")
  
  some.member.events <- subset(member.events, 
                               member_id %in% members[(index.divisions[i]+1) : (index.divisions[i+1])]) 
  partitioned.data <- ddply(some.member.events, 
                            .(member_id), PartitionEvents, partition.num, 
                            .parallel=F, .progress="text")
  
  cat("    Persisting the partitions in a csv file...")
  write.csv(partitioned.data, 
            file = paste("data_output/partitions/member_partitions_", i,".csv", sep = ""), 
            row.names = F)
  
  cat(" ")
}
