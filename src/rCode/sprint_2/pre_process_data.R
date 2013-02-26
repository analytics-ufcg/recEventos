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
# File: partition_data.R
#   * Description: This file partition the events chronologically in 10 different
#                  data splits of train/test. Then a figure is generated to 
#                  support the partition quality analysis
#   * Inputs: the data_csv directory containing the events, rsvps and group csv 
#             files
#   * Outputs: the data_output directory with the data_partitions.csv file 
#              containing the events by city partitioned chronologically and; the 
#              data_partition_analysis-member_count.png figure with histograms
#              that support the analysis of the partitions by counting the  
#              members per data split (train and test).
# =============================================================================

rm(list=ls())

# =============================================================================
# source() and library()
# =============================================================================
source("src/rCode/common.R")

# =============================================================================
# Function definitions
# =============================================================================

# =============================================================================
# Executable Script
# =============================================================================

print(noquote("Processing VENUEs table: Rewriting the city names..."))
venues <- read.csv("data_csv/venues.csv")

# TODO (augusto) : Editar a coluna city das venues para evitar que a mesma cidade 
# seja considerada cidades diferentes por diferenças de escrita
