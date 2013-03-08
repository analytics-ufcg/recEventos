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
#   * Description: Summary stats script that generate extra graphics to support 
#                  the recommendation result analysis
#   * Inputs: The RSVP csv files
#   * Outputs: The PMF, CDF and Bar char of the events per member count.
# =============================================================================
rm(list = ls())

# =============================================================================
# source() and library()
# =============================================================================

source("src/rCode/common.R")

# =============================================================================
# Executable script
# =============================================================================
# TODO (Augusto) - Recommendation focus
# 7 - Nº de eventos por membro por cidade

print(noquote("Reading the RSVPs..."))

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
print(noquote("Generating the PMF with the event count per member"))

png("data_output/summary_stats/pmf-events_per_member.png", width = 800, height = 700)
plot(prop.table(table(member.event.count$freq)), las = T,
     main = "Events per Member\nProbability Mass Function", 
     col = "blue", xlab = "Events per Member", ylab = "Frequency")
dev.off()


# Cumulative Distribution Function
print(noquote("Generating the CDF with the event count per member"))

png("data_output/summary_stats/cdf-events_per_member.png", width = 800, height = 700)
plot(Ecdf(~ member.event.count$freq, scales=list(x=list(log=T)),
          q=c(.6, .7, .8, .9, .95, .99), main = "Events per Member\nCumulative Distribution Function", 
          xlab = "Events Number", ylab = "Members Quantile"))
dev.off()


# Bar chart
print(noquote("Generating Bar chart with the event count per member"))

png("data_output/summary_stats/barchart-events_per_member.png", width=1200, height=800)
print(ggplot(member.event.count, aes(x = member_id, y = freq)) + 
        geom_bar(aes(fill = freq), stat = "identity", .binwidth = .1) + 
        xlab("Members") + ylab ("Number of Events"))
dev.off()


# -----------------------------------------------------------------------------
# Count the MEMBER EVENTs per CITY
# -----------------------------------------------------------------------------
# members <- read.csv("data_csv/members_1.csv")[,c("id", "city")]
# members <- ReadAllCSVs(dir="data_csv/", obj_name="members")[, c("id", "city")]
# 
# print(noquote("Generating bar charts of events per member BY city "))
# 
# member.events.per.city <- count(member.events.partitions, vars=c("member_city", "member_id"))
# 
# png("data_output/data_partition_analysis-member_events_count.png", width=2000, height=1600)
# print(ggplot(member.events.per.city, aes(x = freq)) + 
#         geom_histogram(binwidth = 1) + 
#         facet_wrap(~ member_city, scales="free") + 
#         xlab("Number of Events") + ylab ("Number of Members"))
# dev.off()
