#install.packages('ggmap')
library(shiny)
library(ggplot2)
library(leaflet)
library(dplyr)
library(wordcloud)
library (ggthemes)
library(RColorBrewer)
library(reshape2)
library(tm)
library(SnowballC)
library(wordcloud2)
library(ggmap)
library(googleVis)
library(DT)
library (shinydashboard)



restaurants_reviews= read.csv('restaurants_reviews_manipulated.csv',header=TRUE)

restaurants = read.csv('restaurant_geoloc.csv',header=TRUE)

restaurants$rating_category=factor(restaurants$rating_category,levels = c('excellent','good','average'))
restaurants$rest_name =factor(restaurants$rest_name, levels = restaurants$rest_name[order(restaurants$rating)])


restaurants_cuisine = read.csv('restaurant_cuisine_geoloc.csv',header=TRUE)

# Average cost
by_avgcost= restaurants_cuisine [!duplicated(restaurants_cuisine$restaurant_name),]%>% select(restaurant_name,average_cost,rating_category) %>% arrange(desc(average_cost))
by_avgcost$restaurant_name <- factor(by_avgcost$restaurant_name,by_avgcost$restaurant_name[order(by_avgcost$average_cost)])


pal=brewer.pal(9, "Dark2")

#cost location
by_neighborhood = restaurants_cuisine[!duplicated(restaurants_cuisine$restaurant_name),] %>% group_by(location) %>% summarise(avg_cost= mean(average_cost)) 

#by reviews
restaurants_reviews = restaurants_reviews %>% group_by(rest_name) %>% mutate(review_count= n()) %>%                     arrange(desc(review_count)) 
restaurants_reviews$rest_name= factor(restaurants_reviews$rest_name, 
                                      restaurants_reviews$rest_name[order(-restaurants_reviews$review_count)]) 