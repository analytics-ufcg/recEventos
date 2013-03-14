# TODO (rodolfo): executar a avaliação e salvar os resultados
rm(list = ls())

source("src/rCode/common.R")
source("src/rCode/sprint_3/recommender_eval_metrics.R")

print(noquote("Reading the MEMBER.EVENTs (if there is any)..."))
member.events <- ReadAllCSVs(dir="data_output/partitions/", obj_name="member_events")

# TODO(rodolfo): for each member and partition, evaluate the recommendations
test.events <- member.events[member.events$member_id == m & 
                               member.events$event_time >= p.time, "event_id"]

# Evaluate the result
precision <- Precision(test.events, rec.events) # For all relevant events
recall <- Recall(test.events, rec.events) # For all relevant events
# ndcg <- NDCG(test.events, rec.events)

# Save the evaluations
dir.create("data_output/recommendations/", showWarnings=F)

print(noquote("Persisting the recommendation evaluations..."))
write.csv(results, 
          file = paste("data_output/recommendations/recommeded_events_eval_",i,".csv", sep = ""), 
          row.names = F)