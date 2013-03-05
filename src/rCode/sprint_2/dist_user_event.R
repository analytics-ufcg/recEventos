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
# File: dist_user_event.R
#
#   * Description: 
#
#   * Inputs: 
#
#   * Outputs: 
#
# =============================================================================

# =============================================================================
# source() and library()
# =============================================================================

require("fossil")

# =============================================================================
# Function definitions
# =============================================================================

venues <- read.csv("data_csv/venues.csv",sep = ",")

k.nearest.events <- function(userLat,userLon,kEvents){
  
  dist.matrix = matrix(data = NA,length(venues$id),1)
  dimnames(dist.matrix) = list(venues$id,c(1))
  distance <- deg.dist(userLon,userLat,venues$lon,venues$lat)
  venue.distance = cbind(venues$id,as.data.frame(distance))
  colnames(venue.distance) = c("venueId","dist")
  venue.distance = venue.distance[order(venue.distance$dist, rev(venue.distance$venueId), decreasing = FALSE), ]
  k.lower.dist = venue.distance$venueId[1:kEvents]
  i = 1
  events.aux = data.frame()
  while(i <= kEvents){
    
    events.aux = events.aux
    events = subset(events.with.location,events.with.location$venue_id == k.lower.dist[i])
    i = i + dim(events)[1]
   
    events.aux = rbind(events,events.aux)
    
  }
  
  return (events.aux)
}
