#############################################################################
# HW3
#############################################################################

# for problem 1 part 2

#clean up
rm(list=ls())

#load data
setwd('~/Dropbox/2017_Classes/Text-Analysis/WUSTL/HW/HW3/')

# read data
unigramNYTimes <- read.csv("DTM_NYTimes.csv", header=T,row.names=NULL)
# check data
str(unigramNYTimes)

# there is a row.names column so I am moving it to dsk column
unigramNYTimes[,2] <- NULL
colnames(unigramNYTimes)[1] <- "dsk"

mat <- unigramNYTimes[,-1] # remove dsk column for the kmean analysis
tmat <- t(mat) # each row is a word, each column is a document ?

# 1) K-means is a clustering approach that belongs to the class of unsupervised statistical learning methods. It separates data into k cluster so that data points in the same cluster are closer to each other. 
# it basically randomly assigns each observation to a cluster, and finds the centroid of each cluster
# how do we choose k?
# A: choose K so that the cluster has the smallest possible within-cluster variation


# create distance matrix for clustering. This is because we calculate within cluster variation as the sum of the Euclidean distance between the data points and their respective cluster centroids
distMat <- dist(tmat, method = "euclidean")
distMat <- as.matrix(distMat)

# Check for the optimal number of clusters given the data based on within-cluster dissimilarity 
wss <- (nrow(distMat)-1)*sum(apply(distMat,2,var))
for (i in 2:20) wss[i] <- sum(kmeans(distMat,
                                     centers=i)$withinss)
pdf(file="optimalCluster.pdf")
plot(1:20, wss, type="b", xlab="Number of Clusters",
     ylab="Within cluster sum of squares",
     main="Finding an Optimal Number of Clusters",
     pch=20, cex=2)
dev.off()
# after 5 clusters, the difference in the within-cluster dissimiliarity is not substantial. I would say the optimal number is 5? - Q: how do I choose?
# draw plot
library(cluster)
n.clust<- 5
set.seed(8675309) ##complicated objective function
k_cluster<- kmeans(distMat, centers = n.clust)
k_cluster
# Within cluster sum of squares by cluster:
#   [1] 22376.10 43778.74 63928.77 73280.29 32444.46
# (between_SS / total_SS =  84.0 %)
table(k_cluster$cluster)
# 1   2   3   4   5 
# 27 140 281 472  80 
pdf(file="cluster.pdf")
clusplot(distMat, k_cluster$cluster) # Q: I am not sure whether this is a good plot. I also drew it when K=2, 3, and 4, they didn't look good either
dev.off()

# 2) K=6
n.clust<- 6
set.seed(8675309) ##complicated objective function
k_cluster6<- kmeans(distMat, centers = n.clust)
k_cluster6
pdf(file="cluster6.pdf")
clusplot(distMat, k_cluster6$cluster)  # does this plot should look better than previous one?
dev.off()


# 3)
# create cluster center based on the kmean output
library(tibble)
DiffFunc <- function(k){
  if (k>5 | k<1){
    return(print("K should be larger than or equal to 1 and less than or equal to 5"))
  } else {
    theta_k <- k_cluster$centers[k,]
    theta_NOTk <- k_cluster$centers[-k,]
    Diff <- as.data.frame(theta_k - (colSums(theta_NOTk)/4))
    Diff <- rownames_to_column(Diff, "words")
    colnames(Diff) <- c("words", "dist")
    Diff.sort <- as.data.frame(Diff[order(Diff$dist, decreasing = TRUE),])
    top10 <- as.data.frame(Diff.sort[1:10,])
  }
  return(top10)
}


# check the function
DiffFunc(4)
DiffFunc(3)
DiffFunc(6)
DiffFunc(0)
# working!



# lastly, sample and read texts assigned to each cluster and produce a hand label
setwd('~/Dropbox/2017_Classes/Text-Analysis/WUSTL/HW/HW3/')
# sampling and reading from the second cluster
set.seed(1234)
sample(which(k_cluster$cluster==2),1)
# second 
# 123
fileName <- "123.txt"
conn <- file(fileName,open="r")
linn <-readLines(conn)
for (i in 1:length(linn)){
  print(linn[i])
}
close(conn)

# as a function,
ReadNYTFunc <- function(m){
  set.seed(1234)
  index <- sample(which(k_cluster$cluster==m),1)
  fileName <- paste(index,".txt", sep='')
  conn <- file(fileName,open="r")
  linn <-readLines(conn)
  for (i in 1:length(linn)){
    print(linn[i])
  }
  close(conn)
}

ReadNYTFunc(2) # lines are truncated

# for problem 2 part c
#clean up
rm(list=ls())

#load data
setwd('~/Dropbox/2017_Classes/Text-Analysis/WUSTL/HW/HW3/')

# read data
NYTimes <- read.csv("NYTAnalysis.csv", header=T,row.names=NULL)
# check data
str(NYTimes)
# before the election=0. Election on Nov 2nd
NYTimes$election <- NA
NYTimes$election[NYTimes$pubdate==1] <- 0
NYTimes$election[NYTimes$pubdate!=1] <- 1
NYTimes$election <- as.factor(NYTimes$election)
# re-evaluate the change variable
NYTimes$positive <- -(NYTimes$Difference)
# fit a model
mod1 <- lm(Difference ~ election + dsk, NYTimes)
summary(mod1)
# expectation: more negative words rate before the election
# result: election treatment is not reliable. However, it seems like Editorial Desk, Foreign Desk, and National Desk seem to have more positive words than other categories.


# Part 3. Run naive bayes
# subset particular dsk
table(NYTimes$dsk)
# Business/Financial Desk          Editorial Desk            Foreign Desk        Health & Fitness 
# 56                      19                      33                       7 
# Metropolitan Desk           National Desk            Science Desk             Sports Desk 
# 6                      76                       6                      43 
# The Arts/Cultural Desk 
# 42 
subdat <- subset(NYTimes, NYTimes$dsk=="Business/Financial Desk" | NYTimes$dsk=="National Desk")
table(subdat$dsk)
subdat$dsk <- factor(subdat$dsk)
table(subdat$dsk)
head(subdat)
subdat <- subdat[,-c(1,5,6,7)]
subdat <- subdat[,-c(5)]
# leave one out CV, calculate NB
library(caret)
library(klaR)
library(e1071)
set.seed(1234)
library(e1071)

p <- rep(NA, nrow(subdat))
for(i in 1:nrow(subdat)){
  model <- naiveBayes(subdat$dsk[-i] ~.,data=subdat[-i,])
  p[i] <- predict(model, subdat[i,-3], type = "raw") # raw will give me a probability
}
mean(p) # average prediction
0.4282862 # does this mean naive bayes predicted about 43%?

# c) 

# ## 65% of the sample size
size <- floor(0.65 * nrow(subdat))
index <- sample(seq_len(nrow(subdat)), size = size)
levels(subdat$dsk) <- make.names(levels(factor(subdat$dsk)))
traindat <- data.matrix(subdat[index,-3])
test <- data.matrix(subdat[-index,-3])
y.train <- factor(subdat[index,3])
y.train <- as.numeric(y.train)-1
y.test <- factor(subdat[-index,3])
y.test <- as.numeric(y.test)
library(MASS)  
library(glmnet) 
# fit the model
fit.lasso <- glmnet(x=traindat, y.train, alpha=1, 
                          family="binomial")
fit.ridge <- glmnet(traindat, y.train,alpha=0,
                          family="binomial")
# 10-fold Cross validation for each alpha = 0, 0.1, ... , 0.9, 1.0
fit.lasso.cv <- cv.glmnet(x=traindat, y.train, type.measure="mse", alpha=1, 
                          family="binomial")

fit.ridge.cv <- cv.glmnet(traindat, y.train, type.measure="mse", alpha=0,
                          family="binomial")
# par(mfrow=c(2,2))
# plot (fit.lasso.cv)
# plot (fit.ridge.cv)
# plot (log (fit.lasso.cv$lambda), fit.lasso.cv$cvm, pch= 10, col="red", xlab = "log(Lambda)", ylab= fit.lasso.cv$name)
# points(log(fit.ridge.cv$lambda), fit.ridge.cv$cvm, pch= 10, col = "blue")
# legend ("topleft", legend = c("alpha=1", "alpha= 0"), pch= 19, col = c("red",  "blue"))
# predict
#' Make predictions on validation dataset 
yhat0 <- predict(fit.lasso.cv, s=fit.lasso.cv$lambda.1se, newx=test)
yhat1 <- predict(fit.ridge.cv, s=fit.ridge.cv$lambda.1se, newx=test)

mse.lasso <- mean(((y.test-1) - yhat0)^2)
# 0.42974
mse.ridge <- mean(((y.test-1) - yhat1)^2)
# 0.4548091

# conclusion: 
Lasso: 42.974%
Ridge: 45.481%
Naive Bayes: 42.82862%

# Overall, all methods seem to return similar result. More accurately, Ridge approach is the most accurate, followed by Lasso and by NB.
# Q. Is this conclusion correct?