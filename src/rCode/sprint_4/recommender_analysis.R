source("src/rCode/common.R")

#######################
## SUMMARY FUNCTIONS ##
#######################
## Summarizes data.
## Gives count, mean, standard deviation, standard error of the mean, and confidence interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the variable to be summariezed
##   groupvars: a vector containing names of columns that contain grouping variables
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the percent range of the confidence interval (default is 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, conf.level=.95, na.rm=FALSE, .drop=TRUE) {
  
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

evaluations <- ReadAllCSVs("data_output/evaluations/", "rec_events_eval")
evaluations <- evaluations[!is.na(evaluations$recall),]


summaryPrec = summarySE(evaluations, "precision", c("partition", "rec_size"), conf.level = .95)
colnames(summaryPrec) <- c("partition", "rec_size", "N", "precision", 
                           "precision_sd", "precision_se", "precision_ci")

summaryRecall = summarySE(evaluations, "recall", c("partition", "rec_size"), conf.level = .95)
colnames(summaryRecall) <- c("partition", "rec_size", "N", "recall", 
                             "recall_sd", "recall_se", "recall_ci")

summaryEvals = cbind(summaryPrec, summaryRecall[, 4:7])

ggplot(summaryEvals, aes(x=rec_size, y=precision)) + 
  geom_errorbar(aes(ymin=precision-precision_ci, ymax=precision+precision_ci), width=.01,  colour = "blue") +
  geom_line(colour = "blue") + geom_point(colour = "blue") + 
  facet_wrap(~partition) +
  ggtitle("Precision by partition and recommendation size") + 
  theme(plot.title = element_text(lineheight=.8, face="bold"))

ggplot(summaryEvals, aes(x=rec_size, y=recall)) + 
  geom_errorbar(aes(ymin=recall-recall_ci, ymax=recall+recall_ci), width=.01,  colour = "red") +
  geom_line(colour = "red") + geom_point(colour = "red") + 
  facet_wrap(~partition) +
  ggtitle("Precision by partition and recommendation size") + 
  theme(plot.title = element_text(lineheight=.8, face="bold"))

