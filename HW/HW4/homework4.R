#############################################################################
# HW4
#############################################################################

# problem 1

#clean up
rm(list=ls())

#load data
setwd('~/Dropbox/2017_Classes/Text-Analysis/WUSTL/HW/HW4/')

# read data
load("~/Dropbox/2017_Classes/Text-Analysis/WUSTL/StudentDrinking.RData")
covariates <- X # covariates
rm(X)

# check data
head(covariates) # where is codebook? url does not working
head(alcohol) # what is the unit? consumption?

# i) linear regression
lm.mod <- lm(alcohol ~ covariates)
summary(lm.mod)
# being male, going out with friends more, and skipping classes have positive influence on alcohol consumption
# studying more time, considering family time have negative influence on alchol consumption


# ii) lasso
library(glmnet) 
glmnet.mod <- cv.glmnet(y=alcohol, x=covariates, alpha=1,family="gaussian", type.measure="mse")
print(glmnet.mod)
plot(glmnet.mod)
glmnet.mod$lambda.min
# 0.05751821
glmnet.mod$lambda.1se
# 0.232202
coef(glmnet.mod, s = glmnet.mod$lambda.min)

# iii) ridge
ridge.mod <- cv.glmnet(y=alcohol, x=covariates, alpha=0,family="gaussian", type.measure="mse")
print(ridge.mod)
plot(ridge.mod)
ridge.mod$lambda.min
# 0.3784314
ridge.mod$lambda.1se
# 4.251011
coef(ridge.mod, s = ridge.mod$lambda.min)

# iv) elastic-net regression
elastic.mod <- cv.glmnet(y=alcohol, x=covariates, alpha=0.5,family="gaussian", type.measure="mse")
print(elastic.mod)
plot(elastic.mod$lambda,elastic.mod$cvm)
plot(elastic.mod)
elastic.mod$lambda.min
# 0.1048169
elastic.mod$lambda.1se
# 0.464404
coef(elastic.mod, s = elastic.mod$lambda.min)

# alpha: alpha is the elasticnet mixing parameter, which ranges from 0 to 1. The penalty is 1 for lasso penalty and 0 for ridge penalty.
# for elastic-net regression, alpha=0.5, which indicates the balance between Lasso and Ridge approaches.

# v)
# Lambda is the tuning parameter which determents the amount of shrinkage

elastic.result <- as.matrix(coef(elastic.mod, s = elastic.mod$lambda))[3,]
elastic.lambda <- elastic.mod$lambda

ridge.result <- as.matrix(coef(ridge.mod, s = ridge.mod$lambda))[3,]
ridge.lambda <- ridge.mod$lambda

lasso.result <- as.matrix(coef(glmnet.mod, s = glmnet.mod$lambda))[3,]
lasso.lambda <- glmnet.mod$lambda

pdf("lambda_male.pdf")
par(mfrow=c(3,1))
plot(elastic.lambda,elastic.result, xlab="Lambda (in Elastic-Net Regression)", ylab="Male Coefficient", ylim=c(0,1.5))
# add line from lm() result
abline(h=0.94083, col="red")
plot(ridge.lambda,ridge.result,xlab="Lambda (in Ridge Regression)", ylab="Male Coefficient", ylim=c(0,1.5))
abline(h=0.94083, col="red")
plot(lasso.lambda,lasso.result,xlab="Lambda (in Lasso Regression)", ylab="Male Coefficient", ylim=c(0,1.5))
abline(h=0.94083, col="red")
dev.off()

# from the plot, we can see that as the tuning parameter lambda increases, the size of the coefficient decreases for all approaches.
# For Ridge regression, as the lambda increases, the coefficient decreases radically. On the other hand, as lambda increases on other two approaches, the size of male coefficient decreases smoothly.
# Intuitively, still not sure how to intrepret this particular plot.


# problem 2

# i)
index <-c(1:20)
x.train <- covariates[-index,]
x.valid <- covariates[index,]
y.train <- alcohol[-index]
y.valid <- alcohol[index]

# ii)
library(randomForest)
for(i in 1:10){
  index <- sample(seq_len(nrow(x.train)), size = 10)
  training.x <- data.matrix(x.train[-index,])
  testing.x <- data.matrix((x.train[index,]))
  training.y <- y.train[-index]
  testing.y <- y.train[index]
  trainingDat <- as.data.frame(cbind(training.y, training.x))
  # linear regression
  lm.mod <- lm(training.y ~ ., data=trainingDat)
  lm.pred <- predict(lm.mod, newdata=as.data.frame(testing.x))
  # Lasso
  lasso.mod <- cv.glmnet(y=training.y, x=training.x, alpha=1,family="gaussian", type.measure="mse") # cv.glmnet does N-fold crossvalidation with N=10 by default
  # print(lasso.mod)
  lasso.pred <- predict(lasso.mod, newx=testing.x, s = lasso.mod$lambda.min) 
  # Ridge
  ridge.mod <- cv.glmnet(y=training.y, x=training.x, alpha=0,family="gaussian", type.measure="mse")
  ridge.pred <- predict(ridge.mod, newx=testing.x, s = ridge.mod$lambda.min)
  # Elastic-Net
  elastic.mod <- cv.glmnet(y=training.y, x=training.x, alpha=0.5,family="gaussian", type.measure="mse")
  elastic.pred <- predict(elastic.mod, newx=testing.x, s = elastic.mod$lambda.min)
  # random forest
  forest.mod <- randomForest(y=training.y, x=training.x)
  forest.pred<- predict(forest.mod, newdata=testing.x)
}

prediction <- cbind(testing.y, lm.pred, lasso.pred, ridge.pred,elastic.pred, forest.pred)
prediction <- as.data.frame(prediction)
names(prediction) <- c("y", "lm", "lasso", "ridge", "elast", "forest")
superleaner <- lm(y ~ .-1, data=prediction)
summary(superleaner)
# coefficients are the weigts
superweights <- superleaner$coefficients

# iii)
wholetraining <- as.data.frame(cbind(x.train, y.train))
# linear regression
lm.train <- lm(y.train ~ ., data=wholetraining)
lm.train.pred <- predict(lm.train, newdata=as.data.frame(x.valid))
# lasso
lasso.train <- cv.glmnet(y=y.train, x=x.train, alpha=1,family="gaussian", type.measure="mse") # cv.glmnet does N-fold crossvalidation with N=10 by default
lasso.train.pred <- predict(lasso.train, newx=x.valid, s = lasso.train$lambda.min) 
# Ridge
ridge.train <- cv.glmnet(y=y.train, x=x.train, alpha=0,family="gaussian", type.measure="mse")
ridge.train.pred <- predict(ridge.train, newx=x.valid, s = ridge.train$lambda.min)
# Elastic-Net
elastic.train <- cv.glmnet(y=y.train, x=x.train, alpha=0.5,family="gaussian", type.measure="mse")
elastic.train.pred <- predict(elastic.train, newx=x.valid, s = elastic.train$lambda.min)
# random forest
forest.train <- randomForest(y=y.train, x=x.train)
forest.train.pred<- predict(forest.train, newdata=x.valid)

# iv)

