# =============================================================================
#   data_summary_2.R
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
# * Goal: This script creates the summary statistics of the 2nd sprint 
#                and some more.
# * Inputs: EVENTs and RSVPs csv data
# * Outputs: A CDF graphich of the members per event
#            A Scatterplot matrix with the comparisons between 3 attributes 
#            related to an event and the amount of of members that atteded, 
#            said 'yes' to RSVP and the max 'yes'
#             * No. of users that said yes vs. # attendants (sprint 3 required)
#             * No. of users that said yes vs. limit of users per event (sprint 3 required)
#             * No. of attendants vs. limit of users per event
# =============================================================================
rm(list = ls())

# =============================================================================
# source() and library()
# =============================================================================
source("src/rCode/common.R")

# =============================================================================
# Executable script
# =============================================================================

cat("Reading the RSVPs...")

rsvps <- ReadAllCSVs(dir="data_csv/", obj_name="rsvps")[, c("member_id", "event_id", "response")]
rsvps <- rsvps[rsvps$response == "yes", c("event_id", "member_id")]
event.members.count <- count(rsvps, "event_id")

rm(rsvps)

# -----------------------------------------------------------------------------
# Generate a .png image showing the CDF of the number of members per event  
# -----------------------------------------------------------------------------
cat("Generating the CDF with the number of MEMBERs per EVENT")

png("data_output/summary_stats/cdf-members_per_event.png", width = 800, height = 700)
plot(Ecdf(~ event.members.count$freq, scales=list(x=list(log=T)),
          q=c(.6, .7, .8, .9, .95, .99), main = "CDF of Members per Event", 
          xlab = "Members Number", ylab = "Event Quantile"))
dev.off()

# ------------------------------------------------------------------------------
# Reading the Events data and Cleaning the attendants "garbage"
# ------------------------------------------------------------------------------
cat("Reading the EVENTs...")

events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[, c("id", "headCount", "rsvp_limit")]
colnames(events) <- c("event_id", "headCount", "rsvp_limit")

cat("Cleaning some garbage (possible outliers, headCount >= 5000)...")
events <- events[events$headCount < 5000,]

# ------------------------------------------------------------------------------
# Generating the matrix scatterplot
# ------------------------------------------------------------------------------
cat("Generating the scatterplot matrix between:")
cat("RSVP yes Limit - AND - RSVP yes - AND - Attendants")

events.data <- merge(events[events$headCount > 0 & events$rsvp_limit > 0,],
           event.members.count, by="event_id", all.x = T)

colnames(events.data) <- c("event_id", "attendants", "limit_rsvp_yes", "actual_rsvp_yes")
events.data[is.na(events.data$actual_rsvp_yes),]$actual_rsvp_yes <- 0

require(GGally)
png("data_output/summary_stats/scatterplot_matrix-attendants_vs_max_members_vs_members_yes.png", 
    width = 1200, height = 1200)
ggpairs(data=events.data, columns=c("limit_rsvp_yes", "actual_rsvp_yes", "attendants"))
dev.off()

# ------------------------------------------------------------------------------
# ANALYSIS:
#   CRAZY number of attendants (headCount):
#   http://www.meetup.com/San-Diego-Harley-and-Cruiser-Riders/events/48133452/
#   http://www.meetup.com/sandiegosportbikemeetupgroup/events/10689528/
#   http://www.meetup.com/VinVillage-SanDiego/
# 
#   Result: How there is no way to 'count the heads' (headCount = attendants' number)
#           automatically (for the best of our knowledge). It seems that the event
#           organizers are sending inconsistent values of headCount to meetup.
# ------------------------------------------------------------------------------
