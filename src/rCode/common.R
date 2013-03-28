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
# File:
#   * Description: 
#   * Inputs: 
#   * Outputs: 
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
library(reshape, warn.conflicts=F, quietly=T, verbose=F)

if (Sys.info()['sysname'] == "Linux"){
  library(doMC, warn.conflicts=F, quietly=T, verbose=F)
  registerDoMC(2)
}else{
  library(doSNOW, warn.conflicts=F, quietly=T, verbose=F)
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

