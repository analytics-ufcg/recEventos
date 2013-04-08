# =============================================================================
#   common.R - All libraries and functions used all over the project
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
library(lubridate, warn.conflicts=F, quietly=T, verbose=F)
library(plyr, warn.conflicts=F, quietly=T, verbose=F)
library(foreach, warn.conflicts=F, quietly=T, verbose=F)
library(iterators, warn.conflicts=F, quietly=T, verbose=F)
library(ggplot2, warn.conflicts=F, quietly=T, verbose=F)
library(stringr, warn.conflicts=F, quietly=T, verbose=F)
library(Hmisc, warn.conflicts=F, quietly=T, verbose=F)
library(oce, warn.conflicts=F, quietly=T, verbose=F)
library(data.table, warn.conflicts=F, quietly=T, verbose=F)
library(reshape2, warn.conflicts=F, quietly=T, verbose=F)

if (Sys.info()['sysname'] == "Linux"){
  library(doMC, warn.conflicts=F, quietly=T, verbose=F)
  registerDoMC(2)
}else{
  library(doSNOW, warn.conflicts=F, quietly=T, verbose=F)
  #   registerDoSNOW(makeCluster(1, type = "SOCK"))
  
}


# =============================================================================
# Function definitions
# =============================================================================
ReadAllCSVs = function(dir, obj_name){
  df = NULL
  for (file in list.files(path = dir, pattern=paste("^", obj_name, "_?[0-9]*.csv", sep = ""))){
    
    # This the optimized version of read.table (the arguments: nrows and colClasses 
    # are not being used because of the wide variety of tables this function reads)
    df = rbind(df, read.table(file = paste(dir, file, sep = ""), header = T, 
                              sep = ",", quote = "\"", dec = ".", fill = T, 
                              stringsAsFactors = F, comment.char = ""))
  }
  return(df)
}

