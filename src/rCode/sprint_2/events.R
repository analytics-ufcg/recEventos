rm(list = ls())

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
users = read.csv("data_csv/members.csv",sep=",")
table[table$Objetos == "users",][2] = length(unique(users$id))

#events/ contagem das linhas do arquivo file events.csv
events1 <- read.csv("data_csv/events_1.csv",sep=",")
table[table$Objetos == "events",][2] = length(unique(events1$id))

#user-group/ contagem das linhas do arquivo group_members.csv
user.group = read.csv("data_csv/group_members.csv",sep = ",")
table[table$Objetos == "user_group",][2] = dim(user.group)[1]

#user-tag/ contagem das linhas do arquivo member_topics.csv
user.tag = read.csv("data_csv/member_topics.csv", sep = ",")
table[table$Objetos == "user_tag",][2] = dim(user.tag)[1]

#users with locations/ numeros de users
table[table$Objetos == "user_with_locations",][2] = 
  length(unique(users[is.numeric(users$lat) && is.numeric(users$lon),]$id))

#user-event/ leitura do arquivo rsvps.csv com todos os members(yes/no)
user.event = read.csv("data_csv/rsvps_1.csv",sep = ",")
table[table$Objetos == "user_event",][2] = dim(user.event)[1]

#user_event_yes/ 
user.event.yes = user.event[user.event$response == "yes",]
table[table$Objetos == "user_event_yes",][2] = dim(user.event.yes)[1]

#events with locations/ tabela events que nao tem venues_id == "NA"
table[table$Objetos == "events_with_locations",][2] = dim(events1[!is.na(events1$venue_id),])[1]

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

png("data_output/eventos_por_cidade.png", width = 600, height = 600)
print(ggplot(events.with.city, aes(x = city)) + geom_bar(binwidth=1) + coord_flip() + labs(x="Cidade",y="Número de Eventos") )
dev.off()

user.event.yes <- within(user.event.yes, 
                           event_id <- factor(event_id,
                                          levels=names(sort(table(event_id),
                                                            decreasing=TRUE))))
png("data_output/membros_por_evento.png", width = 900, height = 600)
print(ggplot(user.event.yes, aes(x = event_id)) + 
        geom_histogram(position="identity")  + 
        labs(x="Eventos",y="Número de Membros") +
        theme(axis.ticks = element_blank(), 
             axis.text.x =  element_blank()))
dev.off()
           
#users
#events
#user_group
#user_tag(falta)
#user_with_location
#user_event
#event_with_location


