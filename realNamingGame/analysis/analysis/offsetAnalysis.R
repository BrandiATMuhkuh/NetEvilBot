
off <- read.csv("robotOffset_full.csv")

off = subset(off, RobotOffset > 49)
(anova(lm(off$stat_5000_robot_percent ~ off$RobotOffset)))
t.test(off$stat_1000_robot_percent ~ off$RobotOffset)
fit = aov(off$stat_1000_robot_percent ~ off$RobotOffset)
summary(fit)
anova(lm(off$stat_1000_robot_percent ~ off$RobotOffset))

a = lm(stat_2500_robot_percent ~ RobotOffset, data=subset(off, Robots. == 3))
b = lm(stat_2500_robot_percent ~ RobotOffset, data=subset(off, Robots. == 6))
c = lm(stat_2500_robot_percent ~ RobotOffset, data=subset(off, Robots. == 9))
anova(a,b,c)
summary(anova(a,b,c))


data70 = subset(subset(off, RobotOffset > 70), Robots. == 9)
data50 = subset(subset(off, RobotOffset > 50), Robots. == 9)
data30 = subset(subset(off, RobotOffset > 30), Robots. == 9)
data10 = subset(subset(off, RobotOffset > 10), Robots. == 9)
lm70 = lm(stat_2500_robot_percent ~ RobotOffset, data70)
lm50 = lm(stat_2500_robot_percent ~ RobotOffset, data50)
lm30 = lm(stat_2500_robot_percent ~ RobotOffset, data30)
lm10 = lm(stat_2500_robot_percent ~ RobotOffset, data10)
anova(lm70,lm50,lm30)



#select only between centrality
data <- read.csv("robotOffset_full.csv")
data = subset(data,  centrality == '"betweenness-centrality"')
#select only data with same mount of robots
data = subset(data, Robots. == 11)
data$RobotOffset = factor(data$RobotOffset)
#compare the dataset on it's robot offset level
model = lm(stat_5000_robot_percent ~ RobotOffset ,data=data)
summary(model)
ano = anova(model)
summary(ano)



