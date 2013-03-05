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
# Author: Augusto Queiroz
#
# File: data_summary_2.R
#   * Description: 
#   * Inputs: 
#   * Outputs:
# =============================================================================
rm(list = ls())

# =============================================================================
# source() and library()
# =============================================================================

source("src/rCode/common.R")

# =============================================================================
# Executable script
# =============================================================================
# # of users that said yes vs. # attendants (sprint 3)
# # of users that said yes vs. limit of users per event (sprint 3)
# # attendants vs. limit of users per event

print(noquote("Reading the EVENTs and RSVPs..."))

# events <- read.csv("data_csv/events_1.csv")[,c("id", "headCount", "rsvp_limit")]
events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[, c("id", "headCount", "rsvp_limit")]
colnames(events) <- c("event_id", "headCount", "rsvp_limit")

# rsvps <- read.csv("data_csv/rsvps_12.csv")[, c("member_id", "event_id", "response")]
rsvps <- ReadAllCSVs(dir="data_csv/", obj_name="rsvps")[, c("member_id", "event_id", "response")]
rsvps <- rsvps[rsvps$response == "yes", c("event_id", "member_id")]
event.members.count <- count(rsvps, "event_id")

rm(rsvps)

print(noquote("Cleaning some garbage (possible outliers, headCount > 10000)..."))
events <- events[events$headCount < 5000,]

print(noquote("Generating the event's scatterplots:"))

# GRAPHIC 1
# print(noquote("     Number of Attendants vs. Number of Members(rsvp: yes)"))
# 
# events.rsvps <- merge(events[events$headCount > 0, c("event_id", "headCount")], 
#                       event.members.count, by = "event_id", all.x = T)
# colnames(events.rsvps) <- c("event_id", "num_attendants", "num_members_yes")
# # Set the NA members with yes to 0
# events.rsvps[is.na(events.rsvps$num_members_yes),]$num_members_yes <- 0
# 
# png("data_output/summary_stats/scatterplot_attendants_vs_members_yes.png", width = 1200, height = 600)
# print(ggplot(events.rsvps, aes(x = num_attendants, y = num_members_yes)) + 
#         geom_point() +
#         labs(x="Number of Attendants", y="Number of Members (rsvp = yes)"))
# dev.off()
# 
# 
# # GRAPHIC 2
# print(noquote("    Limit of Members vs. Number of members(rsvp: yes)"))
# 
# events.rsvps2 <- merge(events[events$rsvp_limit > 0, c("event_id", "rsvp_limit")], 
#                       event.members.count, by = "event_id", all.x = T)
# colnames(events.rsvps2) <- c("event_id", "max_num_members", "num_members_yes")
# # Set the NA members with yes to 0
# events.rsvps2[is.na(events.rsvps2$num_members_yes),]$num_members_yes <- 0
# 
# png("data_output/summary_stats/scatterplot_max_members_vs_members_yes.png", width = 1200, height = 600)
# print(ggplot(events.rsvps2, aes(x = max_num_members, y = num_members_yes)) + 
#         geom_point() +
#         labs(x="Limit of Members", y="Number of Members (rsvp = yes)"))
# dev.off()
# 
# 
# # GRAPHIC 3
# print(noquote("    Number of Attendants vs. Limit of Members"))
# 
# png("data_output/summary_stats/scatterplot_attendants_vs_max_members.png", width = 1200, height = 600)
# print(ggplot(events[events$headCount > 0 & events$rsvp_limit > 0,], 
#              aes(x = headCount, y = rsvp_limit)) + 
#         geom_point() +
#         labs(x="Number of Attendants", y="Limit of Members"))
# dev.off()



# CRAZY number of attendants (headCount):
# http://www.meetup.com/San-Diego-Harley-and-Cruiser-Riders/events/48133452/
# http://www.meetup.com/sandiegosportbikemeetupgroup/events/10689528/
# http://www.meetup.com/VinVillage-SanDiego/
# 
# OBS: it seems to me that the event creators are tweaking the Number of Attendants
# just to increase the visibility of the group


# All together
print(noquote("    Matrix: RSVP yes Limit vs. RSVP yes vs. Attendants"))
events.data <- merge(events[events$headCount > 0 & events$rsvp_limit > 0,],
           event.members.count, by="event_id", all.x = T)

colnames(events.data) <- c("event_id", "attendants", "limit_rsvp_yes", "actual_rsvp_yes")

events.data[is.na(events.data$actual_rsvp_yes),]$actual_rsvp_yes <- 0

require(GGally)
png("data_output/summary_stats/scatterplot_matrix_attendants_vs_max_members_vs_members_yes.png", 
    width = 800, height = 800)
ggpairs(data=events.data, columns=c("limit_rsvp_yes", "actual_rsvp_yes", "attendants"))
dev.off()

