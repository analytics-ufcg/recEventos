# =============================================================================
#   data_prep_process.R
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
# * Goal:
# * Inputs
# * Outputs:
# =============================================================================

# =============================================================================
# source() and library()
# =============================================================================
source("src/rCode/common.R")

# =============================================================================
# Executable Script
# =============================================================================

cat("Reading the venues...")
venues <- read.csv("data_csv/venues.csv")

cat("Rewriting the cities collumn from the VENUEs table")
# Regex algorithm
# 1 - Exclude the state names and single letter cities
# 2 - Substitute digits and punctuations with an whitespace
# 3 - Substitute all sequential whitespaces with only one
# 4 - Delete the trailling and last whitespace
# 5 - Turn all words lowercase
# 6 - Turn all words Camel Case

venues$city <- as.factor(gsub("(?:\\b)([[:alpha:]])", "\\U\\1", 
                              tolower(
                                str_replace_all(
                                  str_replace_all(
                                    str_replace_all(
                                      str_replace_all(as.character(venues$city), 
                                                      " [A-Z]{2,3} | [A-Z]{2,3}$|^[[:alpha:]]{1}$", ""),   
                                      "[[:digit:]]+|[[:punct:]]+", " "),
                                    "[ \t]+"," "),
                                  "^[ \t]+|[ \t]+$|", "")
                              ), 
                              perl=T)
                         )

cat("Rewriting the VENUEs table")
write.csv(venues, file = "data_csv/venues.csv", row.names = F)
