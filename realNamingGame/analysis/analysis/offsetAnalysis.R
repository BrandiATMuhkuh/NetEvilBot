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
summary(anova(a,b,c))
