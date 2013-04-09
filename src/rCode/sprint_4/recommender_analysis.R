# =============================================================================
#   recommender_analysis.R
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
# * Goal:
# * Inputs
# * Outputs:
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
  
  # This does the summary; it's not easy to understand...
  datac <- ddply(idata.frame(data), groupvars, .drop=.drop,
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

cat("Reading Recommender Evaluations...\n")
evaluations <- ReadAllCSVs("data_output/evaluations/", "rec_events_[[:alpha:]]+_eval")
evaluations <- evaluations[!is.na(evaluations$recall),]

# -----------------------------------------------------------------------------
# Preparing the evaluation data to plot the COMPLETE RESULTS
# -----------------------------------------------------------------------------
cat("Calculating the summary metrics...\n")
summaryPrec = summarySE(evaluations, "precision", c("algorithm", "partition", "rec_size"), conf.level = .95)
summaryRecall = summarySE(evaluations, "recall", c("algorithm", "partition", "rec_size"), conf.level = .95)

summaryEvals = rbind(melt(summaryPrec, measure.vars = "precision", variable_name = "eval_metric"),
                     melt(summaryRecall, measure.vars = "recall", variable_name = "eval_metric"))

dir.create("data_output/evaluations/analysis", showWarnings=F)

cat("Plotting the Precision and Recall for: All Cities\n")
for (p in 1:max(summaryEvals$partition)){
  cat("  Partition ", p, "...\n", sep = "")
  output.dir <- paste("data_output/evaluations/analysis/partition_", p, "/", sep = "")
  dir.create(output.dir, showWarnings=F)
  
  pdf(paste(output.dir, "precision_recall-all.pdf", sep = ""), width=10, height=5)
  print(ggplot(summaryEvals, aes(x=rec_size, y=value, colour = algorithm)) + 
          geom_errorbar(aes(ymin=value-ci, ymax=value+ci), width=.1) +
          geom_line() + geom_point() + 
          facet_wrap(~variable, ncol=4) +
          ggtitle("Precision and Recall Evaluation (per Partition)\nALL cities") + 
          theme(plot.title = element_text(lineheight=.8, face="bold")))
  dev.off()
}
cat("\n")

# -----------------------------------------------------------------------------
# Preparing the evaluation data to plot the RESULTS by CITY
# -----------------------------------------------------------------------------
cat("Reading the MEMBERs and selecting with MEMBER_EVENTs...\n")
member.ids <- unique(ReadAllCSVs("data_output/partitions/", "member_events")[,"member_id"])
members <- ReadAllCSVs("data_csv/", "members")
members <- subset(members, id %in% member.ids, select=c("id", "city"))

num.cities <- 10
cat("Selecting the members from the", num.cities, "biggest cities...\n")

members.per.city <- count(members, "city")
members.per.city <- members.per.city[order(members.per.city$freq, decreasing = T),]
cities.count <- members.per.city[1:num.cities,]
cities.count$city <- as.character(cities.count$city)
members <- subset(members, city %in% cities.count$city)

cat("Selecting the evaluations of the selected members only...\n")
evaluations <- merge(evaluations, members, by.x = "member_id", by.y = "id")

cat("Re-Calculating the summary metrics...\n")
summaryPrec = summarySE(evaluations, "precision", c("city", "algorithm", "partition", "rec_size"), conf.level = .95)
summaryRecall = summarySE(evaluations, "recall", c("city",  "algorithm", "partition", "rec_size"), conf.level = .95)

summaryEvals = rbind(melt(summaryPrec, measure.vars = "precision", variable_name = "eval_metric"),
                     melt(summaryRecall, measure.vars = "recall", variable_name = "eval_metric"))

cat("Re-Plotting the Precision and Recall for them...\n")
for (p in 1:max(summaryEvals$partition)){
  cat("  Partition ", p, "...\n", sep = "")
  output.dir <- paste("data_output/evaluations/analysis/partition_", p, "/", sep = "")
  dir.create(output.dir, showWarnings=F)
  
  for (i in 1:nrow(cities.count)){
    city <- cities.count$city[i]
    count <- cities.count$freq[i]
    cat("    Re-Plotting the Precision and Recall for:", city, "\n")
    pdf(paste(output.dir, "precision_recall-", i, "-", city, ".pdf", sep=""), width=10, height=5)
    print(ggplot(summaryEvals[summaryEvals$city == city,], aes(x=rec_size, y=value, colour=algorithm)) + 
            geom_errorbar(aes(ymin=value-ci, ymax=value+ci), width=.1) +
            geom_line() + geom_point() + 
            facet_wrap(~variable, ncol=4) +
            ggtitle(label=paste("Precision and Recall Evaluation (per Partition)\n", 
                                city, " (", count, " members)", sep="")) + 
            theme(plot.title = element_text(lineheight=.8, face="bold")))
    dev.off()
  }
}