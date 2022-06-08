#Final Project K-means Part

library(tidyverse)
library(ggplot2)


#Get the data:

spotify_songs <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-01-21/spotify_songs.csv')


#scale

set.seed(42)

spotify_songs_c <- scale(spotify_songs[,12:23])

apply(spotify_songs_c,2,sd) 

apply(spotify_songs_c,2,mean) 

six <- kmeans(spotify_songs_c,6,nstart=25)


#Looks like 1 is rap. 2 is rock. 3/4 not so decisive（3 pop, 4 latin）. 5 r&b, 6 edm
six$centers

table(six$cluster,spotify_songs$playlist_genre)


#plot:


#black is edm, pink is r&b
cluster_color<-six$cluster
  
i <- sample(1:nrow(spotify_songs))  

plot(spotify_songs$acousticness[i], spotify_songs$instrumentalness[i],
     pch=21, cex=.75, bty="n",
     xlab="acousticness",
     ylab="instrumentalness",
     bg=c("maroon","gold", 'blue', 'green', 'pink', 'black')[cluster_color[i]],
     col=c("maroon","gold", 'blue', 'green', 'pink', 'black')[spotify_songs$playlist_genre[i]])

#Maroon is rap, gold is rock

cluster_color<-six$cluster

i <- sample(1:nrow(spotify_songs))  

plot(spotify_songs$danceability[i], spotify_songs$speechiness[i],
     pch=21, cex=.75, bty="n",
     xlab="danceability",
     ylab="speechiness",
     bg=c("maroon","gold", 'blue', 'green', 'pink', 'black')[cluster_color[i]],
     col=c("maroon","gold", 'blue', 'green', 'pink', 'black')[spotify_songs$playlist_genre[i]])

##histogram by mode(Useful or not?)

ggplot(data=spotify_songs, aes(x=mode,fill = playlist_genre)) + geom_histogram()

# create a big long vector of clusters
# takes a bit of time 
# you'll also get warnings of non-convergence;
# this isn't too bad; it just means things look 
# longer than the allotted 10 minimization iterations.

kfit <- lapply(1:200, function(k) kmeans(spotify_songs_c,k))

# choose number of clusters?

source("kIC.R") ## utility script

# you give it kmeans fit, 
# then "A" for AICc (default) or "B" for BIC

kaicc <- sapply(kfit,kIC)

kbic <- sapply(kfit,kIC,"B")

## plot 'em

plot(kaicc, xlab="K", ylab="IC", 
     ylim=range(c(kaicc,kbic)), # get them on same page
     bty="n", type="l", lwd=2)

abline(v=which.min(kaicc))

lines(kbic, col=4, lwd=2)

abline(v=which.min(kbic),col=4)

# both AICc and BIC choose very complicated models


# you get too big, and you lose interpretive power.
# no clear role of what to do here, it depends what you want.
# we'll just focus on k=30, where the BIC starts to level out

k=30

tapply(spotify_songs$track_popularity,kfit[[k]]$cluster,mean)


# let's see how cluster work:

library(gamlr)

xclust <- sparse.model.matrix(~factor(kfit[[k]]$cluster)+spotify_songs$playlist_genre) # cluster membership matrix

wineregclust <- cv.gamlr(xclust,spotify_songs$track_popularity,lambda.min.ratio=1e-5) # 

plot(wineregclust)

max(1-wineregclust$cvm/wineregclust$cvm[1]) # OOS R2 around 0.05

## we end up doing a better job just regressing onto raw x;

library(gamlr)  


spotify_raw <- spotify_songs[,c(4,12:23)]

# create matrix of all three way interactions


x <- model.matrix(track_popularity~.^3, data=spotify_raw)[,-1]

winereg <- cv.gamlr(x,spotify_raw$track_popularity,lambda.min.ratio=1e-5)

plot(winereg)

max(1-winereg$cvm/winereg$cvm[1]) # max OOS R2 on y of about 0.088






# text analysis/topic modelling (Using the sparsematrix created by Zihan Zhu):

set.seed(10086)


## Topic modelling: we'll choose the number of topics
## Recall: BF is like exp(-BIC), so you choose the bigggest BF
tpcs <- topics(spm_name,K=2:25)


## interpretation
# ordering by `topic over aggregate' lift:
summary(tpcs, n=5) 
# ordered by simple in-topic prob
print(rownames(tpcs$theta)[order(tpcs$theta[,3], decreasing=TRUE)[1:10]])
print(rownames(tpcs$theta)[order(tpcs$theta[,4], decreasing=TRUE)[1:10]])



## Wordles!  Again, in my fit looks like 1 is gop, 2 is dems
library(wordcloud)
par(mfrow=c(1,2))
wordcloud(row.names(tpcs$theta), 
          freq=tpcs$theta[,1], min.freq=0.004, col="maroon")
wordcloud(row.names(tpcs$theta), 
          freq=tpcs$theta[,2], min.freq=0.004, col="navy")


spotify_songs



#### WEEK 9 TREES STUFF

library(gamlr)

## new packages

library(tree)

library(randomForest)


genre <- spotify_songs$playlist_genre

## tree fit; it knows to fit a classification tree since genre is a factor.

## for two-level factors (e.g. spam) make sure you do factor(spam)

genretree <- tree(as.factor(genre) ~ ., data=spotify_songs[,12:23], mincut=5)

## tree plot

plot(genretree, col=1, lwd=2)

## print the predictive probabilities

text(genretree,cex=2)

genrepred <- predict(genretree, newdata=spotify_songs[,12:23], type="class")

table(genrepred ,spotify_songs$playlist_genre)


## example of prediction (type="class"  to get max prob classifications back)




## example of random forest for classification

genrerf <- randomForest(as.factor(genre) ~ ., data=spotify_songs[,12:23], importance=TRUE)

varImpPlot(genrerf,type=1)

## random forest also just gives you the max prob class.
genrerfclass <- predict(genrerf, newdata=spotify_songs[,12:23])


table(genrerfclass,spotify_songs$playlist_genre)

#predicting popularity

## First, lets do it with CART
## no need for interactions; the tree finds them automatically

catree <- tree(track_popularity ~ ., data=spotify_raw) 

plot(catree, col=8, lwd=2)

text(catree,cex=3)

## Almost no predicting power 

cvca <- cv.tree(catree)

cvca$size[which.min(cvca$dev)]

plot(cvca)