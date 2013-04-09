# =============================================================================
#   data_summary_extra.R
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
# * Goal: Summary stats script that generate extra graphics to support 
#                the recommendation result analysis
# * Inputs: The RSVP csv files
# * Outputs: The PMF, CDF and Bar char of the events per member count.
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

# rsvps <- read.csv("data_csv/rsvps_12.csv")[, c("member_id", "event_id", "response")]
rsvps <- ReadAllCSVs(dir="data_csv/", obj_name="rsvps")[, c("member_id", "event_id", "response")]
rsvps <- rsvps[rsvps$response == "yes", c("member_id", "event_id")]
rsvps$member_id <- as.factor(rsvps$member_id)

member.event.count <- count(rsvps, "member_id")
member.event.count$member_id <- factor(member.event.count$member_id, 
                                       levels = member.event.count[order(member.event.count$freq, 
                                                                         decreasing=T), "member_id"])

rm(rsvps)

# -----------------------------------------------------------------------------
# MEMBER EVENTs analysis
# -----------------------------------------------------------------------------

# Probabilistic Mass Function
cat("Generating the PMF with the event count per member")

png("data_output/summary_stats/pmf-events_per_member.png", width = 800, height = 700)
plot(prop.table(table(member.event.count$freq)), las = T,
     main = "Events per Member\nProbability Mass Function", 
     col = "blue", xlab = "Events per Member", ylab = "Frequency")
dev.off()


# Cumulative Distribution Function
cat("Generating the CDF with the event count per member"))

png("data_output/summary_stats/cdf-events_per_member.png", width = 800, height = 700)
plot(Ecdf(~ member.event.count$freq, scales=list(x=list(log=T)),
          q=c(.6, .7, .8, .9, .95, .99), main = "Events per Member\nCumulative Distribution Function", 
          xlab = "Events Number", ylab = "Members Quantile"))
dev.off()


# Bar chart
cat("Generating Bar chart with the event count per member (10.000 first members with more events)")

png("data_output/summary_stats/barchart-events_per_member.png", width=1200, height=800)
print(ggplot(member.event.count[1:10000,], aes(x = member_id, y = freq)) + 
        geom_bar(aes(fill = freq), stat = "identity", .binwidth = .1) + 
        xlab("Members") + ylab ("Number of Events"))
dev.off()

