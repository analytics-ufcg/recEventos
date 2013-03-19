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
# Author: Augusto Queiroz de Macedo
#
# File: recommender_analysis.R
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
# Function definition
# =============================================================================

summarySE <- function(data=NULL, measurevar, groupvars=NULL, conf.level=.95, na.rm=FALSE, .drop=TRUE) {
  ## Summarizes data.
  ## Gives count, mean, standard deviation, standard error of the mean, and confidence interval (default 95%).
  ##   data: a data frame.
  ##   measurevar: the name of a column that contains the variable to be summariezed
  ##   groupvars: a vector containing names of columns that contain grouping variables
  ##   na.rm: a boolean that indicates whether to ignore NA's
  ##   conf.interval: the percent range of the confidence interval (default is 95%)
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This is does the summary; it's not easy to understand...
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun= function(xx, col, na.rm) {
                   c( N    = length2(xx[,col], na.rm=na.rm),
                      mean = mean   (xx[,col], na.rm=na.rm),
                      sd   = sd     (xx[,col], na.rm=na.rm)
                   )
                 },
                 measurevar,
                 na.rm
  )
  
  
  # Rename the "mean" column    
  datac <- rename(datac, c("mean"=measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate normal distribution/t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  if (length(df) >= 30){
    # normal distribution
    ciMult = qnorm((1 + conf.level)/2)
  }else{
    # t-student distribution
    ciMult = qt((1 + conf.level)/2, datac$N-1)
  }
  datac$ci <- datac$se * ciMult
  
  return(datac)
}

# =============================================================================
# Main
# =============================================================================

print(noquote("Reading Recommender Evaluations..."))
evaluations <- ReadAllCSVs("data_output/evaluations/", "rec_events_eval")
evaluations <- evaluations[!is.na(evaluations$recall),]

# -----------------------------------------------------------------------------
# Preparing the evaluation data to plot the COMPLETE RESULTS
# -----------------------------------------------------------------------------
print(noquote("Calculating the summary metrics..."))
summaryPrec = summarySE(evaluations, "precision", c("partition", "rec_size"), conf.level = .95)
summaryRecall = summarySE(evaluations, "recall", c("partition", "rec_size"), conf.level = .95)

summaryEvals = rbind(melt(summaryPrec, measure.vars = "precision", variable_name = "eval_metric"),
                     melt(summaryRecall, measure.vars = "recall", variable_name = "eval_metric"))

dir.create("data_output/evaluations/analysis", showWarnings=F)
print(noquote("Plotting the Precision and Recall for: All Cities"))
png("data_output/evaluations/analysis/precision_recall-all.png", width=1200, height=350)
print(ggplot(summaryEvals, aes(x=rec_size, y=value, colour = eval_metric)) + 
  geom_errorbar(aes(ymin=value-ci, ymax=value+ci), width=.1) +
  geom_line() + geom_point() + 
  facet_wrap(~partition, ncol=4) +
  ggtitle("Precision and Recall Evaluation (per Partition)\nALL cities") + 
  theme(plot.title = element_text(lineheight=.8, face="bold")))
dev.off()

# -----------------------------------------------------------------------------
# Preparing the evaluation data to plot the RESULTS by CITY
# -----------------------------------------------------------------------------
print(noquote("Reading the MEMBERs data..."))
members <- ReadAllCSVs("data_csv/", "members")[,c("id", "city")]

num.cities <- 10
print(noquote(paste("Selecting the members from the", num.cities, "biggest cities...")))

members.per.city <- count(members, "city")
members.per.city <- members.per.city[order(members.per.city$freq, decreasing = T),]
cities.count <- members.per.city[1:num.cities,]
cities.count$city <- as.character(cities.count$city)
members <- members[members$city %in% cities.count$city,]

print(noquote(paste("Selecting the evaluations of the selected members only...")))
evaluations2 <- merge(evaluations, members, by.x = "member_id", by.y = "id")

print(noquote("Re-Calculating the summary metrics..."))
summaryPrec2 = summarySE(evaluations2, "precision", c("city", "partition", "rec_size"), conf.level = .95)
summaryRecall2 = summarySE(evaluations2, "recall", c("city", "partition", "rec_size"), conf.level = .95)

summaryEvals2 = rbind(melt(summaryPrec2, measure.vars = "precision", variable_name = "eval_metric"),
                      melt(summaryRecall2, measure.vars = "recall", variable_name = "eval_metric"))

for (i in 1:nrow(cities.count)){
  city <- cities.count$city[i]
  count <- cities.count$freq[i]
  print(noquote(paste("Re-Plotting the Precision and Recall for:", city)))
  png(paste("data_output/evaluations/analysis/precision_recall-", i, "-", city, ".png", sep=""), width=1200, height=350)
  print(ggplot(summaryEvals2[summaryEvals2$city == city,], aes(x=rec_size, y=value, colour=eval_metric)) + 
          geom_errorbar(aes(ymin=value-ci, ymax=value+ci), width=.1) +
          geom_line() + geom_point() + 
          facet_wrap(~partition, ncol=4) +
          ggtitle(label=paste("Precision and Recall Evaluation (per Partition)\n", city, " (", count, " members)", sep="")) + 
          theme(plot.title = element_text(lineheight=.8, face="bold")))
  dev.off()
}