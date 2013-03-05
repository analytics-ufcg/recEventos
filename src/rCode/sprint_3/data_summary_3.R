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
# TODO (Augusto) - Recommendation focus
# 5 - Nº de eventos por membro
# 6 - Nº de eventos por membro por cidade
# 7 - CDF dos eventos por membro

print(noquote("Reading the MEMBERs and RSVPs..."))

# events <- read.csv("data_csv/events_1.csv")[,c("id", "headCount", "rsvp_limit")]
# events <- ReadAllCSVs(dir="data_csv/", obj_name="events")[, c("id", "headCount", "rsvp_limit")]
# colnames(events) <- c("event_id", "headCount", "rsvp_limit")

# rsvps <- read.csv("data_csv/rsvps_12.csv")[, c("member_id", "event_id", "response")]
rsvps <- ReadAllCSVs(dir="data_csv/", obj_name="rsvps")[, c("member_id", "event_id", "response")]
rsvps <- rsvps[rsvps$response == "yes", c("event_id", "member_id")]

print(noquote("Cleaning some garbage (possible outliers, headCount > 10000)..."))
events <- events[events$headCount < 10000,]

# -----------------------------------------------------------------------------
# Count the MEMBER EVENTs per CITY
# -----------------------------------------------------------------------------
# 
# print(noquote("Generating bar charts by city with the event count per member, partition and data_split"))
# 
# member.events.per.city <- count(member.events.partitions, vars=c("member_city", "member_id"))
# 
# png("data_output/data_partition_analysis-member_events_count.png", width=2000, height=1600)
# print(ggplot(member.events.per.city, aes(x = freq)) + 
#         geom_histogram(binwidth = 1) + 
#         facet_wrap(~ member_city, scales="free") + 
#         xlab("Number of Events") + ylab ("Number of Members"))
# dev.off()

