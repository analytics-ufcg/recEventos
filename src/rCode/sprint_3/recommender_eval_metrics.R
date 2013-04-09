# =============================================================================
#   recommender_eval_metrics.R
#   Copyright (C) 2013  Rodolfo Martins
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
#   * Goal: 
#   * Inputs: 
#   * Outputs:
# =============================================================================

Precision = function(test.events, rec.events){
  return(length(intersect(test.events, rec.events))/length(rec.events))
}

Recall = function(test.events, rec.events){
  return(length(intersect(test.events, rec.events))/length(test.events))
}


