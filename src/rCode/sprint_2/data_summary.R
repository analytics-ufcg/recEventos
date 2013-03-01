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
# File: data_sumary.R
#   * Description: This file summarize the data colletion.Read the files .csv of reasearch objects
#   * Inputs: the data_csv directory containing the events, rsvps, group, group_events, group_members, 
#             group_topics, member_topics, venues csv files.
#
#   * Outputs: Two images .png, EVENTS_PER_CITY.png and MEMBERS_PER_EVENT.png
# =============================================================================
rm(list = ls())

# =============================================================================
# source() and library()
# =============================================================================

rm(list = ls())
source("src/rCode/common.R")
require("plyr")
require("ggplot2")

# =============================================================================
# Executable script
# =============================================================================

table = data.frame(Objetos = c("users",
                               "events",
                               "user_group",
                               "user_tag",
                               "user_with_locations",
                               "user_event",
                               "user_event_yes",
                               "events_with_locations",
                               "groups",
                               "tags",
                               "group_tag"),
                   Qnt = c(1:11))
table[,2] = "NULL"

# -----------------------------------------------------------------------------
# Read the file members.csv and count number of users
# -----------------------------------------------------------------------------
print(noquote("Reading members..."))

users = ReadAllCSVs(dir="data_csv/", obj_name="members")
table[table$Objetos == "users",][2] = length(unique(users$id))

# -----------------------------------------------------------------------------
# Count number of users with locatins
# -----------------------------------------------------------------------------
print(noquote("Reading user-with-locations..."))

table[table$Objetos == "user_with_locations",][2] = 
  length(unique(users[is.numeric(users$lat) && is.numeric(users$lon),]$id))

rm(users)

# -----------------------------------------------------------------------------
# Read all the files events_[1..*].csv and count number of events
# -----------------------------------------------------------------------------
print(noquote("Reading events..."))

events1 <- ReadAllCSVs(dir="data_csv/", obj_name="events")
table[table$Objetos == "events",][2] = length(unique(events1$id))

# -----------------------------------------------------------------------------
# Count the events with locations
# -----------------------------------------------------------------------------
print(noquote("Reading events-with-locations..."))

table[table$Objetos == "events_with_locations",][2] = dim(events1[!is.na(events1$venue_id),])[1]
#rm(events1)

# -----------------------------------------------------------------------------
# Read the file group_members.csv and count number of pair group-member
# -----------------------------------------------------------------------------
print(noquote("Reading group-members..."))

user.group = read.csv("data_csv/group_members.csv",sep = ",")
table[table$Objetos == "user_group",][2] = dim(user.group)[1]

# -----------------------------------------------------------------------------
# Read the file members_topics.csv and count number of pair member-topic
# -----------------------------------------------------------------------------
print(noquote("Reading member-topics..."))

user.tag = read.csv("data_csv/member_topics.csv", sep = ",")
table[table$Objetos == "user_tag",][2] = dim(user.tag)[1]

# -----------------------------------------------------------------------------
# Read all the files rsvps[1..*].csv and count number of users that 
# answer(yes/no) for events
# -----------------------------------------------------------------------------
print(noquote("Reading rsvps..."))

user.event = ReadAllCSVs(dir="data_csv/", obj_name="rsvps")
table[table$Objetos == "user_event",][2] = dim(user.event)[1]

# -----------------------------------------------------------------------------
# Read all the files rsvps[1..*].csv and count number of users that 
# answer(yes) for events
# -----------------------------------------------------------------------------
print(noquote("Reading user-event-yes..."))

user.event.yes = user.event[user.event$response == "yes",]
table[table$Objetos == "user_event_yes",][2] = dim(user.event.yes)[1]

# -----------------------------------------------------------------------------
# Read the file groups.csv and count number of groups
# -----------------------------------------------------------------------------
print(noquote("Reading groups..."))

groups = read.csv("data_csv/groups.csv",sep=",")
table[table$Objetos == "groups",][2] = length(unique(groups$id))

# -----------------------------------------------------------------------------
# Read the file topics.csv and count number of topics
# -----------------------------------------------------------------------------
print(noquote("Reading topics..."))

topics = read.csv("data_csv/topics.csv",sep=",")
table[table$Objetos == "tags",][2] = length(unique(topics$id))

# -----------------------------------------------------------------------------
# Read the file groups_topics.csv and count number of pair group-tag
# -----------------------------------------------------------------------------
print(noquote("Reading group-topics..."))

group.tag = read.csv("data_csv/group_topics.csv",sep = ",")
table[table$Objetos == "group_tag",][2] = dim(group.tag)[1]


# -----------------------------------------------------------------------------
# Generate a .png image showing the number of events per cities  
# -----------------------------------------------------------------------------
print(noquote("Generating the histogram with the number of EVENT per CITY..."))

events.with.city = merge(events1[,c("id", "time", "group_id")], 
                         groups[,c("id", "city")], 
                         by.x = "group_id", 
                         by.y = "id", 
                         all.x = T)

events.with.city <- within(events.with.city, 
                           city <- factor(city,
                                          levels=names(sort(table(city),
                                                            decreasing=FALSE))))

dir.create("data_output",showWarnings=F)

png("data_output/EVENTS_PER_CITY.png", width = 1200, height = 1600)
print(ggplot(events.with.city, aes(x = city)) + geom_bar(binwidth=1) + coord_flip() + labs(x="Cidade",y="Número de Eventos") )
dev.off()

# -----------------------------------------------------------------------------
# Generate a .png image showing the number of members per event  
# -----------------------------------------------------------------------------

print(noquote("Generating the histogram with the number of MEMBERs per EVENT..."))

user.event.yes.filt <- user.event.yes[,5:6]
user.event.yes.filt = count(user.event.yes.filt,vars= "event_id")
user.event.yes$event_id <- factor(user.event.yes$event_id,
                                  levels = as.character(user.event.yes.filt[order(user.event.yes.filt$freq, decreasing=T), "event_id"]))

<<<<<<< HEAD
png("data_output/membros_por_evento.png", width = 1600, height = 1000)
m <- ggplot(user.event.yes[1:100000,], aes(x = event_id)) +  geom_histogram() + labs(x="Eventos",y="Número de Membros")
=======
png("data_output/MEMBERS_PER_EVENT.png", width = 1600, height = 1000)
m <- ggplot(user.event.yes, aes(x = event_id)) +  geom_histogram() + labs(x="Eventos",y="Número de Membros")
>>>>>>> 61d33606c285f7f1b60c2ec80c0ae4bfad5c722d
print(m)
dev.off()
