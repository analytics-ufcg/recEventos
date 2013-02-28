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
# Author: Elias Paulino
#
# File: sumarizacao.R
#   * Description: This file summarize the data
#   * Inputs: the data_csv directory containing the events, rsvps and group csv 
#             files
#   * Outputs: the data_output directory with the data_partitions.csv file 
#              containing the events by city partitioned chronologically and; the 
#              data_partition_analysis-member_count.png figure with histograms
#              that support the analysis of the partitions by counting the  
#              members per data split (train and test).
# =============================================================================

rm(list = ls())

source("src/rCode/common.R")

require("plyr")
require("ggplot2")


table = data.frame(Objetos = c("users",
                               "events",
                               "user_group",
                               "user_tag",
                               "user_with_locations",
                               "user_event",
                               "user_event_yes",
                               "events_with_locations",
                               "groups",
                               "tags",
                               "group_tag"),
                                Qnt = c(1:11))
table[,2] = "NULL"




#users/ contagem das linhas do arquivo members.csv
users = ReadAllCSVs(dir="data_csv/", obj_name="members")
table[table$Objetos == "users",][2] = length(unique(users$id))

#users with locations/ numeros de users
table[table$Objetos == "user_with_locations",][2] = 
  length(unique(users[is.numeric(users$lat) && is.numeric(users$lon),]$id))

rm(users)


#events/ contagem das linhas do arquivo file events.csv
events1 <- ReadAllCSVs(dir="data_csv/", obj_name="events")
table[table$Objetos == "events",][2] = length(unique(events1$id))

#events with locations/ tabela events que nao tem venues_id == "NA"
table[table$Objetos == "events_with_locations",][2] = dim(events1[!is.na(events1$venue_id),])[1]



#rm(events1)

#user-group/ contagem das linhas do arquivo group_members.csv
user.group = read.csv("data_csv/group_members.csv",sep = ",")
table[table$Objetos == "user_group",][2] = dim(user.group)[1]

#user-tag/ contagem das linhas do arquivo member_topics.csv
user.tag = read.csv("data_csv/member_topics.csv", sep = ",")
table[table$Objetos == "user_tag",][2] = dim(user.tag)[1]


#user-event/ leitura do arquivo rsvps.csv com todos os members(yes/no)
#user.event = read.csv("data_csv/rsvps_1.csv",sep = ",")
user.event = read.csv("data_csv/rsvps_1.csv") #ReadAllCSVs(dir="data_csv/", obj_name="rsvps")
table[table$Objetos == "user_event",][2] = dim(user.event)[1]

#user_event_yes/ 
user.event.yes = user.event[user.event$response == "yes",]
table[table$Objetos == "user_event_yes",][2] = dim(user.event.yes)[1]


#groups/ feito um unique no vetor groups$id
groups = read.csv("data_csv/groups.csv",sep=",")
table[table$Objetos == "groups",][2] = length(unique(groups$id))

#tags/ feito um unique no vetor topics$id
topics = read.csv("data_csv/topics.csv",sep=",")
table[table$Objetos == "tags",][2] = length(unique(topics$id))

#group-tag/ dimesao da tabela group_tag 
group.tag = read.csv("data_csv/group_topics.csv",sep = ",")
table[table$Objetos == "group_tag",][2] = dim(group.tag)[1]


events.with.city = merge(events1[,c("id", "time", "group_id")], 
                         groups[,c("id", "city")], 
                         by.x = "group_id", 
                         by.y = "id", 
                         all.x = T)


events.with.city <- within(events.with.city, 
                   city <- factor(city,
                   levels=names(sort(table(city),
                   decreasing=FALSE))))

dir.create("data_output",showWarnings=F)

theme_set(theme_bw())

png("data_output/eventos_por_cidade.png", width = 900, height = 1000)
print(ggplot(events.with.city, aes(x = city)) + geom_bar(binwidth=1) + coord_flip() + labs(x="Cidade",y="Número de Eventos") )
dev.off()

user.event.yes.filt <- user.event.yes[,5:6]
user.event.yes.filt = count(user.event.yes.filt,vars= "event_id")
user.event.yes$event_id <- factor(user.event.yes$event_id,
                                       levels = as.character(user.event.yes.filt[order(user.event.yes.filt$freq), "event_id"]))

# x <- user.event.yes
# x$event_id <- as.character(x$event_id)

theme_set(theme_bw())

png("data_output/membros_por_evento.png", width = 1600, height = 1000)
m <- ggplot(user.event.yes, aes(x = event_id)) + 
  geom_histogram() + 
  labs(x="Eventos",y="Número de Membros")
print(m)
dev.off()

#write.table(table,"data_output/tabela_sumarizacao.csv")
#+ theme(axis.ticks = element_blank(), axis.text.x =  element_blank())           
#users
#events
#user_group
#user_tag(falta)
#user_with_location
#user_event
#event_with_location


