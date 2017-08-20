#ranks <- read_csv("ranks.csv")
dataBig <- read.csv("ranksFriends.csv")
data <- read.csv("ranksFriends2.csv")

len = 236

rank = c(1:len, 1:len, 1:len)
friends = c(dataBig$bFriends[1:len],dataBig$cFriends[1:len], dataBig$pFriends[1:len])
students = c(dataBig$bStudent[1:len],dataBig$cStudent[1:len], dataBig$pStudent[1:len])
type = c(rep("betweeness", len),rep("closeness", len),rep("pageRank", len))


model = lm(data$rank ~ data$friends*data$type)
summary(model)
model = lm(rank ~ friends*type)
summary(model)
ano = anova(model)
ano
summary(ano)



#run this code on https://www.rdocumentation.org/packages/lmtest/versions/0.9-35/topics/grangertest
#d = url("https://gist.githubusercontent.com/BrandiATMuhkuh/397b5dc922366273564c5ce4a4917876/raw/9d6ce0999aa530ff68cc9f46b3c8ba41fbc15732/ranksFriends.csv")
#dataBig <- read.csv(d)

#grangertest(bStudent ~ cStudent, data = dataBig)
#grangertest(cStudent ~ pStudent, data = dataBig)
#grangertest(pStudent ~ bStudent, data = dataBig)


#Visual analysis with corrgram
dataBig <- read.csv("ranksFriends.csv")
dataBig = dataBig[c("bStudent", "cStudent", "pStudent")]
dataBig = dataBig[1:200,]
corrgram(dataBig, order=TRUE, lower.panel=panel.shade,
         upper.panel=panel.pie, text.panel=panel.txt,
         main="Car Milage Data in PC2/PC1 Order")

corrgram(dataBig, order=TRUE, lower.panel=panel.ellipse,
         upper.panel=panel.pts, text.panel=panel.txt,
         diag.panel=panel.minmax, 
         main="Car Mileage Data in PC2/PC1 Order")


