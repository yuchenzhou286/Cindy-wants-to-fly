This project is the final project of BUS 41200 Big Data at Booth, University of chicago.
I cooperated with my group members Kemin Wang and Zihan Zhu. 

Below are the general introduction of our project and the main questions that we have tried to answer. 

Spotify is a common app for people to enjoy music and it contains a large amount of music songs. It is one of the largest music streaming service providers, with over 422 million monthly active users, including 182 million paying subscribers, as of March 2022. Since we are curious about the music trends of the past decades in the US, we choose to analyze the music trend and genre in the US, using the dataset from Spotify. Musical genre is far from black and white - there are no hard and fast rules for classifying a given track or artist as “hard rock” vs. “folk rock,” but rather the listener knows it when they hear it. Is it possible to classify songs into broader genres? And what can quantitative audio features tell us about the qualities of each genre? By thinking about the above questions and implementing what we learned from class, we will be able to figure out several models that fit the data and develop our own prediction model.

Our data set comes from tidytuesday, an R-based data library that contains many useful clean data sets. Originally, the raw data can be achieved from spotifyr package, which was developed by Charlie Thompson, Josiah Parry, Donal Phipps, and Tom Wolff. For simplicity, we use data collected by Kaylin Pavilk, who had a recent blogpost using the audio features to explore and classify songs. She used the spotifyr package to collect about 5000 songs from 6 main categories (EDM, Latin, Pop, R&B, Rap, & Rock).


The main questions that have been explored:

1. Despite the artist, what features best contribute to the popularity of a song? Features here can be the words on album, the words on playlist, the words on song’s name, or the genre of song.
2. Do musical characteristics correctly identify a song’s genre?
3. Based on the second question, can we develop strong explanatory variables for popularity based on musical characteristics?
4. Which playlists, artists, and albums are the most popular?

We applied Lasso and CV Lasso to find out the most important features that decides a song’s popularity.
We applied k-means clustering, the tree method, and random forest to identify songs' genre. 
We then plotted the network of playlists, artists, and albums, ranked their popularity and got their betweenness.



