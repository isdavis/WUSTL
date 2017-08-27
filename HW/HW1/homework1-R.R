#############################################################################
# HW1 part 3
#############################################################################

#clean up
rm(list=ls())

#load data
setwd('~/Dropbox/2017_Classes/Text-Analysis/WUSTL/HW/HW1/')
debate <- read.csv("HWdebate.csv")
str(debate)

##compare overall positive and negative word rate
PosRate<-with(debate, tapply(NumPositive, speaker, mean))
PosRate
LEHRER    OBAMA   ROMNEY 
1.013699 8.575000 6.203704 
# Obama's has the highest rate, followed by Romney and Lehrer.

NegRate<-with(debate, tapply(NumNegative, speaker, mean))
NegRate
LEHRER     OBAMA    ROMNEY 
0.4657534 2.7500000 2.4074074
# Obama's has the highest rate, followed by Romney and Lehrer. Unlike previous one, the difference between Obama and Romney is minimal.

## Visualize ##
pdf(file="positiverate.pdf")
barplot(PosRate, main="Positive Words Rate")
dev.off()
pdf(file="negativerate.pdf")
barplot(NegRate, main="Negative Words Rate")
dev.off()

### Trend ###
debate<- debate[order(debate$statementNumber),]
# a. Tone
pdf(file="tone.pdf")
par(mfrow=c(3,1))
plot(NumNegative~statementNumber, data=debate[debate$speaker=="OBAMA",], type="l", col="red", main="Obama", ylab="rate")
lines(NumPositive~statementNumber, data=debate[debate$speaker=="OBAMA",], type="l", col="green")
plot(NumNegative~statementNumber, data=debate[debate$speaker=="OBAMA",], type="l", col="red", main="LEHRER", ylab="rate")
lines(NumPositive~statementNumber, data=debate[debate$speaker=="OBAMA",], type="l", col="green")
plot(NumNegative~statementNumber, data=debate[debate$speaker=="OBAMA",], type="l", col="red", main="Romney", ylab="rate")
lines(NumPositive~statementNumber, data=debate[debate$speaker=="OBAMA",], type="l", col="green")
dev.off()

# b. response
debate$previous<- rep(NA, nrow(debate))
for (i in 2:nrow(debate)){
  debate$previous[i]<- as.character(debate$speaker[i-1])
}
debate$previousNegRate<- rep(NA, nrow(debate))
debate$previousPosRate<- rep(NA, nrow(debate))
for (k in 2:nrow(debate)){
  debate$previousNegRate[k]<- debate$NumPositive[k-1]
  debate$previousPosRate[k]<- debate$NumNegative[k-1]
}
previousNegRate<-with(debate, tapply(previousNegRate, speaker, mean))
previousNegRate
LEHRER    OBAMA   ROMNEY 
NA 3.300000 1.685185 
previousPosRate<-with(debate, tapply(previousPosRate, speaker, mean))
previousPosRate
LEHRER     OBAMA    ROMNEY 
NA 1.3750000 0.6296296 

# Obama is more responsive than Romney. In addition, their negative response rates are similar. Obama's positive response rate is a lot higher than Romney's.

mod1<- lm(NumNegative~previousPosRate + previousNegRate, debate)
summary(mod1)
# not reliable
mod2<- lm(NumPositive~previousPosRate + previousNegRate, debate)
summary(mod2)
# not reliable

# Overall, it is interesting that Obama was more responsive than Romeny during the debate.  
