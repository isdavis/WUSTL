#############################################################################
# HW2 part 2 and 3
#############################################################################

#clean up
rm(list=ls())

#load data
setwd('~/Dropbox/2017_Classes/Text-Analysis/WUSTL/HW/HW2/')
unigram <- read.csv("unigrams1000.csv")
trigram <- read.csv("trigrams500.csv")
str(unigram)
str(trigram)

# convert frequencies to rates
subuni <- unigram[,-c(1,2)] # remove speaker and file
for (i in 1:nrow(unigram)){
  subuni[i,]<- subuni[i,]/(sum(subuni[i,])) # 
}
unigram_rate <- cbind(unigram[,c(1,2)], subuni) # add speaker and file again

subtri <- trigram[,-c(1,2)]
for (i in 1:nrow(trigram)){
  subtri[i,]<- subtri[i,]/(sum(subtri[i,]))
}
trigram_rate <- cbind(trigram[,c(1,2)], subtri)


# mean and variance by Sessions and Shelby
# unigram
meanShelby<-apply(unigram_rate[unigram_rate$speaker=="Shelby", -c(1,2)], 2, mean,na.rm=T)
meanSessions <-apply(unigram_rate[unigram_rate$speaker=="Sessions", -c(1,2)], 2, mean,na.rm=T) 

varShelby<-apply(unigram_rate[unigram_rate$speaker=="Shelby", -c(1,2)], 2, var,na.rm=T)
varSessions <-apply(unigram_rate[unigram_rate$speaker=="Sessions", -c(1,2)], 2, var,na.rm=T) 

# trigram
TrimeanShelby<-apply(trigram_rate[trigram_rate$speaker=="Shelby", -c(1,2)], 2, mean, na.rm=T)
TrimeanSessions <-apply(trigram_rate[trigram_rate$speaker=="Sessions", -c(1,2)], 2, mean,na.rm=T) 

TrivarShelby<-apply(trigram_rate[trigram_rate$speaker=="Shelby", -c(1,2)], 2, var,na.rm=T)
TrivarSessions <-apply(trigram_rate[trigram_rate$speaker=="Sessions", -c(1,2)], 2, var,na.rm=T) 

# 1. Mosteller and Wallace LDA
unigram_lda <- (meanShelby-meanSessions)/(varShelby-varSessions)
unigram_lda
trigram_lda <- (TrimeanShelby-TrimeanSessions)/(TrivarShelby-TrivarSessions)
trigram_lda

# 2. Standardeized mean difference
table(unigram$speaker)
# Sessions   Shelby 
# 236     1102 

unigram_sd_mean_diff <- (meanShelby - meanSessions)/sqrt((varShelby/236) + (varSessions/1102))
trigram_sd_mean_diff <- (TrimeanShelby - TrimeanSessions)/sqrt((TrivarShelby/236) + (TrivarSessions/1102))

# 3. standardized log odds
# unigram
ShelbyCol <- colSums(unigram[unigram$speaker=="Shelby", -c(1,2)])
SessionsCol <- colSums(unigram[unigram$speaker=="Sessions", -c(1,2)])

Shelby_p<- (ShelbyCol + 1)/(sum(ShelbyCol) + 1001)
Sessions_p<- (SessionsCol + 1)/(sum(SessionsCol) + 1001)

LogOdds_uni <- log(Shelby_p/ (1- Shelby_p)) - log(Sessions_p/ (1-Sessions_p))
VarLogOdds_uni <- (1/(ShelbyCol + 1)) + (1/(SessionsCol + 1)) 
sdLogOdds<- LogOdds_uni/ sqrt(VarLogOdds_uni)

# trigram
ShelbyCol.tri <- colSums(trigram[trigram$speaker=="Shelby", -c(1,2)])
SessionsCol.tri <- colSums(trigram[trigram$speaker=="Sessions", -c(1,2)])

Shelby_p.tri<- (ShelbyCol.tri + 1)/(sum(ShelbyCol.tri) + 501)
Sessions_p.tri<- (SessionsCol.tri + 1)/(sum(SessionsCol.tri) + 501)

LogOdds_tri <- log(Shelby_p.tri/ (1- Shelby_p.tri)) - log(Sessions_p.tri/ (1-Sessions_p.tri))
VarLogOdds_tri <- (1/(ShelbyCol.tri + 1)) + (1/(SessionsCol.tri + 1)) 
sdLogOdds.tri<- LogOdds_tri/ sqrt(VarLogOdds_tri)



# plot all measures

# sort each measure (increasing order)
lda_tri <- trigram_lda[order(trigram_lda)]
lda_uni <- unigram_lda[order(unigram_lda)]

sd_mean_uni <- unigram_sd_mean_diff[order(unigram_sd_mean_diff)]
sd_mean_tri <- trigram_sd_mean_diff[order(trigram_sd_mean_diff)]

sdLogOdds <- sdLogOdds[order(sdLogOdds)]
sdLogOdds.tri <- sdLogOdds.tri[order(sdLogOdds.tri)]

# trigram plots
pdf(file="Plot_measure_tri.pdf")
par(mfrow=c(3,1))
index<- seq(1, 21, 1)
plot(lda_tri[c(1:10,490:500)],index,xlab="weight",xlim=c(-15, 170),ylab="", pch="", main="Most discriminating words in LDA")
text(lda_tri[c(1:10,490:500)], index , label=names(lda_tri[c(1:10,490:500)]), cex=.6, col="red")

plot(sd_mean_tri[c(1:10,490:500)],index, xlim=c(-25, 10), ylab="",xlab="weight",pch='', main="Most discriminating words in Standardized Mean difference")
text(sd_mean_tri[c(1:10,490:500)], index , label=names(sd_mean_tri[c(1:10,490:500)]), cex=.6, col="red")

plot(sdLogOdds.tri[c(1:10,490:500)],index,xlim=c(-10, 5),  ylab="",xlab="weight",pch='', main="Most discriminating words in Standardized Log Odds")
text(sdLogOdds.tri[c(1:10,490:500)], index , label=names(sdLogOdds.tri[c(1:10,490:500)]), cex=.6, col="red")
dev.off()


# unigram plots
pdf(file="Plot_measure_uni.pdf")
par(mfrow=c(3,1))
index<- seq(1, 21, 1)
plot(lda_uni[c(1:10,490:500)],index,xlab="weight",ylab="", pch="", main="Most discriminating words in LDA")
text(lda_uni[c(1:10,490:500)], index , label=names(lda_uni[c(1:10,490:500)]), cex=.6, col="red")

plot(sd_mean_uni[c(1:10,490:500)],index, ylab="",xlab="weight",pch='', main="Most discriminating words in Standardized Mean difference")
text(sd_mean_uni[c(1:10,490:500)], index , label=names(sd_mean_uni[c(1:10,490:500)]), cex=.6, col="red")

plot(sdLogOdds[c(1:10,490:500)],index,ylab="",xlab="weight",pch='', main="Most discriminating words in Standardized Log Odds")
text(sdLogOdds[c(1:10,490:500)], index , label=names(sdLogOdds[c(1:10,490:500)]), cex=.6, col="red")
dev.off()

# Depends on which measure the researcher uses, the weights will be calculated differently. 
# for unigram, it seems like log odds measure can show discriminating words more clearly (words are further apart).
# On the other hand, for trigram case, LDA measure is more appropriate.


# Comparing document similiarity between two speakers

# sample words
index.1<- sample(which(trigram$speaker=="Shelby"), 100, replace=F)
index.2<- sample(which(trigram$speaker=="Sessions"), 100, replace=F)
# create matrix
index<- c(index.1, index.2)
TrigramWords<- trigram[index,]
ids<-subset(TrigramWords[,1:2])
ids$file <- as.character(ids$file)
ids$speaker <- as.character(ids$speaker)
# remove ids
TrigramWords<- as.matrix(TrigramWords[,-c(1,2)])
# remove missing columns (words=0)
TrigramWords <- TrigramWords[,which(!apply(TrigramWords,2,FUN = function(x){all(x == 0)}))] # 43 columns will be omitted
# TrigramWords 200 by 457 



# 1. Euclidean distance between documents

distMatrix<- matrix(nrow=200, ncol=200)

EDistance<- function(x, y){
  return(sqrt(sum((x-y)^2)))        
}

for (i in 1:nrow(TrigramWords)){
  for (j in 1:nrow(TrigramWords)){
    if (is.na(distMatrix[i,j])==T){
      ds<- EDistance(TrigramWords[i,], TrigramWords[j,])
      distMatrix[i,j]<- ds
      distMatrix[j,i]<- ds
    }
  }
}

distMatrix # check

# 2. Euclidean distance between documents with tf-idf weights

tfidfFun<- function(x){
  return(log(200/length(which(x>0))))
}

idf <- as.matrix(t(apply(TrigramWords, 1, function(x) x*apply(TrigramWords, 2, tfidfFun))))
tfidfMatrix<-as.matrix(dist(idf, method="euclidean"))

tfidfMatrix # check

# 3. Cosine similarity between documents

CosineMatrix<- matrix(nrow=200, ncol=200)
library(lsa)
for (i in 1:200){
   for (j in 1:200){
       theta<- cosine(TrigramWords[i,], TrigramWords[j,])
       CosineMatrix[i, j]<- theta
       CosineMatrix[j, i]<- theta
   }
}

CosineMatrix # check
# NaN due to some infinity values...In line 141, I already removed all-0-vector. How can I fix this?
# 

# 4. Cosine similarity between documents with tf-idf weights


CosineMatrix2<- matrix(nrow=200, ncol=200)
for (i in 1:nrow(idf)){
  for (j in 1:nrow(idf)){
    theta <- cosine(idf[i,], idf[j,])
    CosineMatrix2[i, j]<- theta
    CosineMatrix2[j, i]<- theta
  }
}

CosineMatrix2 # check
# same problem with #3. NaN values exist.

# 5. Normalize the rows of the trigram document term matrix. 
normalized <- TrigramWords
for (i in 1:200){
  normalized[i,]<- TrigramWords[i,]/sum(TrigramWords[i,])
}

normalized # check

sigma <-c(0, 1, 10, 50, 100) # apply different values of sigma
result <- vector("list", 5) 
for(i in 1:5){ # Start the loop
  result[[i]] <- exp(-(as.matrix(dist(normalized)))/sigma[i])
}

result[1] # check
result[2] # check

# with tf-idf weights

tfidf <- apply(normalized, 2, tfidfFun)
normalized_tfidf<- as.matrix(t(apply(normalized, 1, function(x) x*tfidf)))

sigma <-c(0, 1, 10, 50, 100) # apply different values of sigma
gauss <- vector("list", 5) 
for(i in 1:5){ # Start the loop
  gauss[[i]] <- exp(-(as.matrix(dist(normalized_tfidf)))/sigma[i])
}

gauss[1] # check
gauss[2] # check



