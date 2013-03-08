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
# Author: Elias Paulino and Augusto
#
# File: data_sumary.R
#   * Description: This file summarize the data colletion. Read the files .csv of
#                  reasearch objects
#   * Inputs: the data_csv directory containing the events, rsvps, group, 
#             group_events, group_members, group_topics, member_topics, venues 
#             csv files.
#   * Outputs: The count table and two png images: events_per_location and 
#              members_per_event.png in the summary_stats directory. 
# =============================================================================
rm(list = ls())

# =============================================================================
# source() and library()
# =============================================================================

source("src/rCode/common.R")

# =============================================================================
# Executable script
# =============================================================================

table = data.frame(metric = c("number_members",
                              "number_members_with_locations",
                              "number_events",
                              "number_events_with_locations",
                              "number_groups",
                              "number_topics",
                              "number_member_group_pairs",
                              "number_member_topic_pairs",
                              "number_group_topic_pairs",
                              "number_member_event_yes_pairs",
                              "number_member_event_pairs"),
                   value = c(1:11))
table[,2] = "NULL"


# -----------------------------------------------------------------------------
# Reading the members and Count the number of members
# -----------------------------------------------------------------------------
print(noquote("Reading the members..."))
members = ReadAllCSVs(dir="data_csv/", obj_name="members")

print(noquote("Counting the number of members"))
table[table$metric == "number_members",][2] = length(unique(members$id))

# -----------------------------------------------------------------------------
# Count number of members with locatins
# -----------------------------------------------------------------------------
print(noquote("Counting the number of members with locations..."))

table[table$metric == "number_members_with_locations",][2] = 
  length(unique(members[is.numeric(members$lat) && is.numeric(members$lon),]$id))

rm(members)

# -----------------------------------------------------------------------------
# Reading the file groups.csv and counting the number of groups
# -----------------------------------------------------------------------------
print(noquote("Reading the groups..."))
groups = read.csv("data_csv/groups.csv",sep=",")

print(noquote("Counting the number of groups..."))
table[table$metric == "number_groups",][2] = length(unique(groups$id))

rm(groups)

# -----------------------------------------------------------------------------
# Reading the file topics.csv and counting the number of topics
# -----------------------------------------------------------------------------
print(noquote("Reading the topics..."))
topics = read.csv("data_csv/topics.csv",sep=",")

print(noquote("Counting the number of topics..."))
table[table$metric == "number_topics",][2] = length(unique(topics$id))


rm(topics)


# -----------------------------------------------------------------------------
# Reading the file groups_topics.csv and counting th number of group-tag pairs
# -----------------------------------------------------------------------------
print(noquote("Reading the group-topics..."))
group.topic = read.csv("data_csv/group_topics.csv",sep = ",")

print(noquote("Counting the group-topics pairs..."))
table[table$metric == "number_group_topic_pairs",][2] = nrow(group.topic)

rm(group.topic)

# -----------------------------------------------------------------------------
# Reading the file group_members.csv and count number of pair group-member
# -----------------------------------------------------------------------------
print(noquote("Reading the group-members..."))
member.group = read.csv("data_csv/group_members.csv",sep = ",")

print(noquote("Counting the number of group-member pairs..."))
table[table$metric == "number_member_group_pairs",][2] = nrow(member.group)

rm(member.group)

# -----------------------------------------------------------------------------
# Reading the file members_topics.csv and counting the number of member-topic pairs
# -----------------------------------------------------------------------------
print(noquote("Reading the member-topics..."))
member.topic = read.csv("data_csv/member_topics.csv", sep = ",")

print(noquote("Counting the number of member-topic pairs..."))
table[table$metric == "number_member_topic_pairs",][2] = nrow(member.topic)

rm(member.topic)

# -----------------------------------------------------------------------------
# Read all the files events_[1..*].csv and Counting the number of events
# -----------------------------------------------------------------------------
print(noquote("Reading the events..."))
events <- ReadAllCSVs(dir="data_csv/", obj_name="events")

print(noquote("Counting the number of events..."))
table[table$metric == "number_events",][2] = length(unique(events$id))

# -----------------------------------------------------------------------------
# Counting the events with locations
# -----------------------------------------------------------------------------
print(noquote("Counting the number of events with locations..."))
table[table$metric == "number_events_with_locations",][2] = sum(!is.na(events$venue_id))

# -----------------------------------------------------------------------------
# Reading all the files rsvps[1..*].csv and counting the number of members that 
# answer(yes/no) for events
# -----------------------------------------------------------------------------
print(noquote("Reading the rsvps..."))
member.event <- ReadAllCSVs(dir="data_csv/", obj_name="rsvps")

print(noquote("Counting the number of member-events pairs..."))
table[table$metric == "number_member_event_pairs",][2] <- nrow(member.event)

# -----------------------------------------------------------------------------
# Reading all the files rsvps[1..*].csv and counting the number of members that 
# answered yes for the event's rsvps
# -----------------------------------------------------------------------------
print(noquote("Counting the number of member-events pairs (with yes)..."))

member.event.yes <- member.event[member.event$response == "yes", 
                                 c("member_id", "event_id")]
table[table$metric == "number_member_event_yes_pairs",][2] <- nrow(member.event.yes)

rm(member.event)

# -----------------------------------------------------------------------------
# Read all events
# -----------------------------------------------------------------------------

venues <- read.csv("data_csv/venues.csv",sep = ",")

# -----------------------------------------------------------------------------
# Printing the resultant summary metric values
# -----------------------------------------------------------------------------
print(noquote("Printing the resultant summary metric values..."))
print(noquote(""))
print(noquote(table))
print(noquote(""))
# -----------------------------------------------------------------------------
# Generate a .png image showing the number of events per cities  
# -----------------------------------------------------------------------------

# Pre-processing and reading the venues
source("src/rCode/sprint_2/data_pre_process.R")

print(noquote("Generating the bar plot with the number of EVENTs per location (min.: 30 events)..."))

events.with.location = merge(events, 
                             venues[,c("id", "city")], 
                         by.x = "venue_id", 
                         by.y = "id")

# Selecting events that are in locations that had more than 1 event
location.count <- count(events.with.location, "city")

selected.locations <- location.count[location.count$freq >= 30, ]
events.with.location <- events.with.location[events.with.location$city %in% 
                                               selected.locations$city,]

# Sorting the events by the location count
selected.locations <- selected.locations[order(selected.locations$freq),]

events.with.location <- within(events.with.location, 
                           city <- factor(city, 
                                          levels = selected.locations$city))


dir.create("data_output",showWarnings=F)
dir.create("data_output/summary_stats",showWarnings=F)

png("data_output/summary_stats/events_per_location.png", width = 1200, height = 2000)
print(ggplot(events.with.location, aes(x = city)) + 
        geom_bar(binwidth=1) + coord_flip() + 
        labs(x="Locations", y="Number of Events") )
dev.off()

rm(events.with.location, selected.locations)

# -----------------------------------------------------------------------------
# Generate a .png image showing the number of members per event  
# -----------------------------------------------------------------------------
sample.size <- 50000
print(noquote(paste("Generating the histogram with the number of MEMBERs per EVENT (sample size: ", 
                    sample.size, ")...", sep = "")))

member.event.yes.count <- count(member.event.yes[sample(1:nrow(member.event.yes), 
                                                        sample.size),], vars= "event_id")
member.event.yes.count <- member.event.yes.count[order(member.event.yes.count$freq, 
                                                       decreasing=T),]
member.event.yes.count$event_id <- factor(member.event.yes.count$event_id, 
                                          levels = member.event.yes.count$event_id)

rm(events, member.event.yes)

png("data_output/summary_stats/members_per_event.png", width = 1600, height = 1000)
print(ggplot(member.event.yes.count, aes(x = event_id, y = freq)) +  
        geom_histogram(stat = "identity", binwidth = .01) +
        labs(x="Events", y="Number of Members"))
dev.off()
