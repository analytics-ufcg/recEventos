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
# Author: Rodolfo Moraes Martins
#
# File: recommender_alg_popularity.R
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
source("src/rCode/common.R")

# =============================================================================
# Inputs
# =============================================================================


# =============================================================================
# Function definitions
# =============================================================================

# ----------------------------------------------------------------------------
# Return k lagest distance between receiver user and all events and then the
# most popular ones.
# ----------------------------------------------------------------------------


normalizacao <- function(vetor){
  v.norm <- (vetor - min(vetor))/(max(vetor) - min(vetor))
  return (v.norm)
}

R_Comb <- function(vetor.dist, vetor.pop){
  alfa <- 0.5
  merged <- merge(events.dist.norm, count.events.norm, by.x="id", by.y="event_id")
  value <- (merged$freq.norm * alfa) + (merged$dist.norm * alfa)
  binded <- cbind(merged, value)
  binded <- binded[order(binded$value, decreasing = T),]
  
  return(binded$id)
}