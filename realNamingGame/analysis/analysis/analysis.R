classroom <- read.csv("classroom_full.csv")


p1000 = lm(stat_1000_robot_percent ~ Robots. + centrality + Robots.:centrality ,data=classroom)
pc1000 = lm(classroom$stat_1000_robot_percent ~ classroom$centrality)
anova(p1000)
anova(pc1000)

catchSet = subset(classroom, classroom$Robots. > 1 & (centrality == '"random"' | centrality == '"betweenness-centrality"'))
t.test(catchSet$stat_1000_robot_percent ~ catchSet$centrality)

catchSet = subset(classroom,  classroom$Robots. > 1 & (centrality == '"random"' | centrality == '"closeness-centrality"'))
t.test(catchSet$stat_1000_robot_percent ~ catchSet$centrality)

catchSet = subset(classroom, classroom$Robots. > 1 & (centrality == '"random"' | centrality == '"page-rank"'))
t.test(catchSet$stat_1000_robot_percent ~ catchSet$centrality)


catchSet = subset(classroom, classroom$Robots. > 1 & (centrality == '"betweenness-centrality"' | centrality == '"page-rank"'))
t.test(catchSet$stat_1000_robot_percent ~ catchSet$centrality)

catchSet = subset(classroom, classroom$Robots. > 1 & (centrality == '"betweenness-centrality"' | centrality == '"closeness-centrality"'))
t.test(catchSet$stat_1000_robot_percent ~ catchSet$centrality)


#0\% (only humans), 3\% , 6\% , 9\% , 11\% , 26\% , 44\% , 85\%.
catchSet = subset(classroom, (centrality == '"closeness-centrality"' | centrality == '"betweenness-centrality"'  | centrality == '"page-rank"'))
summary(lm(stat_5000_robot_percent ~ centrality ,data=catchSet))

catchSet = subset(classroom, classroom$Robots. > 1)
boxplot(catchSet$stat_1000_robot_percent ~ catchSet$centrality*catchSet$Robots., col=(c("blue","yellow", "orange",  "green")), outline = FALSE)


#anova centrality  ~ stat_5000_robot_percent
classroom <- read.csv("classroom_full.csv")
plot(classroom$stat_5000_robot_percent ~ classroom$centrality)
mod1 = lm(classroom$stat_5000_robot_percent ~ classroom$centrality)
summary(mod1)


#calc the averages
print("betweenness-centrality")
summary(subset(classroom, classroom$Robots. > 1 & (centrality == '"betweenness-centrality"'))$stat_5000_robot_percent)
sd(subset(classroom, classroom$Robots. > 1 & (centrality == '"betweenness-centrality"'))$stat_5000_robot_percent)

print("closeness-centrality")
summary(subset(classroom, classroom$Robots. > 1 & (centrality == '"closeness-centrality"'))$stat_5000_robot_percent)
sd(subset(classroom, classroom$Robots. > 1 & (centrality == '"closeness-centrality"'))$stat_5000_robot_percent)

print("page-rank")
summary(subset(classroom, classroom$Robots. > 1 & (centrality == '"page-rank"'))$stat_5000_robot_percent)
sd(subset(classroom, classroom$Robots. > 1 & (centrality == '"page-rank"'))$stat_5000_robot_percent)

print("random")
summary(subset(classroom, classroom$Robots. > 1 & (centrality == '"random"'))$stat_5000_robot_percent)
sd(subset(classroom, classroom$Robots. > 1 & (centrality == '"random"'))$stat_5000_robot_percent)

