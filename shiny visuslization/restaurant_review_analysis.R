#install.packages('ggmap')
library('shiny')
library('ggplot2')
library('plotly')
library('leaflet')
library('dplyr')
library(wordcloud)
library (ggthemes)
library(RColorBrewer)
library(reshape2)
library(tm)
library(SnowballC)
library (wordcloud2)
library (ggmap)

restaurants_reviews= read.csv('C:/Users/SPD/PythonBasics/Bootcamp/webscrapingProject/restaurant_review.csv',header=TRUE)
# to go to preprocessing file
# get longitude and latiude info

#restaurants = read.csv('C:/Users/SPD/PythonBasics/Bootcamp/webscrapingProject/restaurant_info_manipulated.csv',header=TRUE)
#restaurants_geocodes= geocode(as.character(restaurants$address))
#restaurants= cbind(restaurants,restaurants_geocodes)
#write.csv(restaurants ,'C:/Users/SPD/PythonBasics/Bootcamp/webscrapingProject/restaurant_geoloc.csv' )

#restaurants_cuisine = read.csv('C:/Users/SPD/PythonBasics/Bootcamp/webscrapingProject/restaurants_cuisine.csv',header=TRUE)
#restaurants_cuisines_geocodes= geocode(as.character(restaurants_cuisine$address))
#restaurants_cuisine= cbind(restaurants_cuisine,restaurants_cuisines_geocodes)
#write.csv(restaurants_cuisine ,'C:/Users/SPD/PythonBasics/Bootcamp/webscrapingProject/restaurant_cuisine_geoloc.csv' )

restaurants = read.csv('C:/Users/SPD/PythonBasics/Bootcamp/webscrapingProject/restaurant_geoloc.csv',header=TRUE)

restaurants$rating_category=factor(restaurants$rating_category,levels = c('excellent','good','average'))
restaurants$rest_name =factor(restaurants$rest_name, levels = restaurants$rest_name[order(restaurants$rating)])


restaurants_cuisine = read.csv('C:/Users/SPD/PythonBasics/Bootcamp/webscrapingProject/restaurant_cuisine_geoloc.csv',header=TRUE)



by_rating=restaurants %>% group_by(rating,rest_name,rating_category) %>% summarise(restaurant_count=n()) 



ggplot(restaurants, aes(x=rest_name,y=rating))+ geom_col(aes(fill=rating_category)) +ggtitle("Restaurants by rating")+theme_classic()+ scale_fill_manual(values=c("steelblue4","steelblue3","lightgrey"))+
  theme(axis.text.x= element_text(angle=0, vjust=0.60),
        plot.title = element_text(hjust=0.5,size= 10),legend.title=element_text(size=10))+ labs(x= "restaurants", y="rating", fill= "rating category", size=10)+ coord_flip()


brks <- seq(0, 1000, 100)

by_avgcost= restaurants_cuisine %>% select(restaurant_name,average_cost,rating_category) %>% arrange(desc(average_cost))
total=600
by_avgcost$padding <- (total - by_avgcost$average_cost) / 2 

molten <- melt(by_avgcost, id.var=c("restarant_name","rating_category"))
molten <- molten[order(molten$variable, decreasing = T), ]

molten$restaurant_name <- factor(molten$rest_name,levels = rev(levels(molten$restaurant_name)))
ggplot(molten, aes(x = restaurant_name)) + 
  geom_bar( aes( y = value, fill = rating_category),stat = "identity", width = .6,position="stack") +  
  
  coord_flip() +
  labs(title="Average cost Of Restaurants") +
  theme_tufte() +  
  theme(plot.title = element_text(hjust = .5), 
        axis.ticks = element_blank()) +   
  scale_fill_brewer(palette = "Accent") 



##Restaurant count by review

by_review = restaurants_reviews %>% group_by(rest_name) %>% summarise(review_count= n()) %>% arrange(desc(review_count)) 
by_review$rest_name= factor(by_review$rest_name, by_review$rest_name[order(-by_review$review_count)])

ggplot(by_review, aes(x=rest_name, y=review_count))+ geom_col( fill = "darkgreen")+
  theme_bw() + labs(x= "Restaurants", y= "reviews", title= "Restaurants by ReviewCounts")+ theme(plot.title =element_text(hjust = .5, size= 10) , axis.text.x = element_text(angle=90, vjust=0.5))

##Wordcloud

m <- list(content = "reviews")
myReader <- readTabular(mapping = m)


review_corpus=Corpus(VectorSource(restaurants_reviews$review))

#remove punctuation
review_corpus = tm_map(review_corpus, removePunctuation)

## remove numbers
review_corpus = tm_map(review_corpus, removeNumbers)

## LowerCase
review_corpus = tm_map(review_corpus, tolower)

words_to_remove=c('york', 'com', 'read', 'nyc', 'read', 'full', 'york', 'restaurant', 'just', 'pig', 'will', 'can', 'much', 'post', 'new','just', 'katz', 'katzs','nobu')

review_corpus = tm_map(review_corpus, removeWords, c(stopwords("english"),words_to_remove))

## treat pre-processed documents as text documents
#review_corpus = tm_map(review_corpus, PlainTextDocument)

## turn into doc matrix
reviews_dtm = DocumentTermMatrix(review_corpus)
reviews_dtm = as.matrix(reviews_dtm)
# displaying most frequent words

#freq = sort(colSums(as.matrix(reviews_dtm)), decreasing=TRUE)
freq= data.frame(Words = colnames(test_dtm), 
      Freq = colSums(test_dtm), 
      row.names = NULL)
freq = freq[order(-freq$Freq),]

head(freq, 20)

pal=brewer.pal(9, "Dark2")

set.seed(100)
wordcloud(words = names(freq), freq = freq, 
          random.order=FALSE,rot.per = .25,
          colors=pal)
wordcloud2(freq, size =0.5, shape = 'circle')

# by neighborhood
by_neighborhood = restaurants_cuisine[!duplicated(restaurants_cuisine$restaurant_name),] %>% group_by(location) %>% summarise(avg_cost= mean(average_cost)) 

#ggplot(by_neighborhood, aes(x=location, y = avg_cost))+ geom_dotplot(aes(),stackgroups = TRUE, binwidth = 1)+ theme(axis.text.x = element_text(angle=90,vjust =0.5) )

by_neighborhoodrating = restaurants_cuisine[!duplicated(restaurants_cuisine$restaurant_name),] %>% group_by(location,rating) %>% summarise(avg_cost= mean(average_cost)) 


library(googleVis)
Area=gvisAreaChart(by_neighborhood)
plot(Area)



restaurants_cuisine[!duplicated(restaurants_cuisine$restaurant_name),]

restaurants_cuisine[!duplicated(restaurants_cuisine$restaurant_name),] %>% 
  ggplot(aes(rating,average_cost))+geom_point(aes(color=location)) + coord_cartesian(xlim = c(3.5,5))+geom_smooth(method='lm',se = FALSE) +theme_classic() 


#restaurants_sub= restaurants_cuisine[!duplicated(restaurants_cuisine$restaurant_name),] %>% select(restaurant_name,location,rating_category)

restaurants_sub = restaurants %>%  select(rest_name,rating,rating_category) %>% group_by(rating_category)
doughnut=gvisPieChart(restaurants_sub, 
                         options=list(
                           width=500,
                           height=500,
                           title='German parliament 2009 - 2013 
                           (Goverment: CDU/FDP/CSU)',
                           legend='rating_category',
                           pieSliceText='label',
                           pieHole=0.5),
                         chartid="doughnut")
plot(doughnut)

ggplot(restaurants_sub, aes(rest_name,rating))+ geom_col(aes(fill=rating_category),position='fill')+coord_polar(theta="y") + theme_classic()+scale_y_continuous()


restaurants_cuisine[!duplicated(restaurants_cuisine$restaurant_name),] %>% group_by(rating_category) %>%
  ggplot(aes(reorder(location,average_cost,mean),average_cost))+
  geom_boxplot(aes(color=rating_category)) + 
  theme_classic()+
  labs(x= "Rating", y= "Cost", title= "Cost by Rating")+              
  theme(plot.title =element_text(hjust = .5, size= 10))

