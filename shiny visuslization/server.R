
function(input,output, session){
  cuisines= reactive({restaurants_cuisine %>% filter(cuisine == input$cuisine)})
  
 # neighborhood = reactive(
     #  {   restaurants_cuisine[!duplicated(restaurants_cuisine$restaurant_name#),] %>%
     #    filter(location == input$location)
     #  }
    # )
  
  rest_reviews= reactive({
    restaurants_reviews %>% filter(rest_name==input$restaurant)
  })
  
  #reactive function for creating term matrix and sentiments for reviews based on input restaurant
  term = reactive({
    review_corpus=Corpus(VectorSource(rest_reviews()$review))
    review_corpus=tm_map(review_corpus, function(x) iconv(enc2utf8(x), sub = "bytes"))
    
    #remove punctuation
    review_corpus = tm_map(review_corpus, removePunctuation)
    
    ## remove numbers
    review_corpus = tm_map(review_corpus, removeNumbers)
    
    ## LowerCase
    review_corpus = tm_map(review_corpus, content_transformer(tolower))
    
    words_to_remove=c('york', 'com', 'read', 'nyc', 'read', 'full', 'york', 'restaurant', 'just', 'pig', 'will', 'can', 'much', 'post', 'new','just', 'katz', 'katzs','nobu', 'candle', 'came', 'went','also','sandwiches', 'korean', 'well', 'danny','madison', 'park', 'eleven', 'katz', 'went','place','burgers','about','know','many','see','one','union', 'ever','restaurants','sandwiches', 'cant', 'joey','yet', 'ajisen','shack',
                      'chicken','john','nobu','about','also','and','but','both','for','were','with','which','any','has','that','shake','food','pigs','harry')
    
    review_corpus = tm_map(review_corpus, removeWords, c(stopwords("english"),words_to_remove))
    
    
    ## turn into doc matrix
    reviews_dtm = DocumentTermMatrix(review_corpus, control = list(weighting = weightTfIdf))
    reviews_dtm = as.matrix(reviews_dtm)
    
    
    # displaying most frequent words
    freq= data.frame(Words = colnames(reviews_dtm), 
                     Freq = colSums(reviews_dtm), 
                     row.names = NULL)
    freq = freq[order(-freq$Freq),]
    freq_up = colSums(as.matrix(reviews_dtm))
    
    #Get the sentiment scores for the words
    sentiments= calculate_sentiment(names(freq_up))
    sentiments = cbind(sentiments, as.data.frame(freq_up))
    
    positive_sentiment = sentiments[sentiments$sentiment == 'Positive',]
    negative_sentiment = sentiments[sentiments$sentiment == 'Negative',]
    
    list(pos_cloud = positive_sentiment, neg_cloud = negative_sentiment)
    
  })
  
  #emotion analysis using syuzhet
  emotions =reactive({review_txt = as.character(rest_reviews()$review) 
  
  ##let's clean html links
  review_txt<-gsub("http[^[:blank:]]+","",review_txt)
  ##let's remove people names
  review_txt<-gsub("@\\w+","",review_txt)
  ##let's remove punctuations
  review_txt<-gsub("[[:punct:]]"," ",review_txt)
  ##let's remove number (alphanumeric)
  review_txt<-gsub("[^[:alnum:]]"," ",review_txt)
  sentimentdata <- get_nrc_sentiment((review_txt))
  
  
  
  list(sentimentdata = sentimentdata)
  })
  
  
   output$restaurant_map = renderLeaflet({
                                leaflet(cuisines()) %>%
                                addTiles() %>%
       addMarkers(popup = ~as.character(c(restaurant_name,address)), 
                         label = ~as.character(restaurant_name))%>%
      addProviderTiles("Esri.WorldStreetMap")
                    
   })
   
   output$rating = renderPlot({
           
           ggplot(restaurants, aes(x=rest_name,y=rating))+ 
           geom_col(aes(fill=rating_category)) +
           ggtitle("Restaurants by Rating")+theme_classic()+ 
           scale_fill_manual(values=c("steelblue4","steelblue3","lightgrey"))+
          coord_flip()+
          theme(axis.text.x= element_text(angle=0, vjust=0.60),
                plot.title = element_text(hjust=0.5,size= 12),
                legend.title=element_text(size=10))+ 
          labs(x= "restaurants", y="rating", fill= "Rating Category", size=10)
     
   })
   
   output$averagecost = renderPlot({
     ggplot(by_avgcost, aes(x = restaurant_name)) + 
       geom_col( aes( y = average_cost), fill = "burlywood4", width = .6, position="stack") +  
       labs(title="Average Cost of Restaurants", x= "Restaurants", y="Cost($)") +
       theme_bw() +  
       theme(plot.title = element_text(hjust = .5), 
             axis.text.x = element_text(angle =90))   
     
   })
   
   
   output$ratingcost = renderPlot({
     restaurants_cuisine[!duplicated(restaurants_cuisine$restaurant_name),] %>% 
       ggplot(aes(rating,average_cost))+
       geom_point(size=2.5) + 
       coord_cartesian(xlim = c(3.5,5)) +
       theme_classic()+
       labs(x= "Rating", y= "Cost($)", title= "Cost by Rating")+              
       theme(plot.title =element_text(hjust = .5, size= 15))
   })
   
   output$reviewcount <- renderInfoBox({
     value = (rest_reviews()[!duplicated(rest_reviews()$rest_name),]$review_count)
     
     infoBox(("Review Count"), value, color= "aqua", fill= TRUE)
   })
   
   output$revrating <- renderInfoBox({
     value = rest_reviews()[!duplicated(rest_reviews()$rest_name),]$rating
     infoBox("rating", value, color= "aqua", fill= TRUE)
   })
   
   
   output$posreviewcloud = renderWordcloud2({
     set.seed((100))
     wordcloud2(term()$pos_cloud[,c(1,3)], size =0.5, shape = 'square', minRotation = 1, maxRotation = 1)
     #wordcloud2(freq, size =0.5, shape = 'circle')
     
   })
   
   
   output$negreviewcloud = renderWordcloud2({
     set.seed(100)
     wordcloud2(term()$neg_cloud[,c(1,3)], size =0.5, shape = 'square',minRotation = 1 )
     
     #wordcloud2(freq, size =0.5, shape = 'circle')
     
   })
   
   output$emotionsplot = renderPlot({
     #print(sum(emotions()$sentimentdata$positive))
     
     # Get the sentiment score for each emotion
     sentimentdata.positive =sum(emotions()$sentimentdata$positive)
     sentimentdata.anger =sum(emotions()$sentimentdata$anger)
     sentimentdata.anticipation =sum(emotions()$sentimentdata$anticipation)
     sentimentdata.disgust =sum(emotions()$sentimentdata$disgust)
     sentimentdata.fear =sum(emotions()$sentimentdata$fear)
     sentimentdata.joy =sum(emotions()$sentimentdata$joy)
     sentimentdata.sadness =sum(emotions()$sentimentdata$sadness)
     sentimentdata.surprise =sum(emotions()$sentimentdata$surprise)
     sentimentdata.trust =sum(emotions()$sentimentdata$trust)
     sentimentdata.negative =sum(emotions()$sentimentdata$negative)
     
     yAxis  = c(sentimentdata.joy,
                + sentimentdata.anticipation,
                + sentimentdata.anger,
                + sentimentdata.disgust,
                + sentimentdata.fear,
                + sentimentdata.sadness,
                + sentimentdata.surprise
     )
     
     xAxis = c("Happy","Anticipation","Anger","Disgust","Fear","Sad","Surprise")
     
     yRange = range(0,yAxis)
     #print(emotions()$yAxis)
     barplot(yAxis, names.arg = xAxis, 
             xlab = "Emotional valence", ylab = "Score", main = "Emotion Analysis", col = brewer.pal(8,'Pastel2'),
             border = "black", ylim = yRange, xpd = F, axisnames = T, cex.axis = 0.8)
     
     #wordcloud2(freq, size =0.5, shape = 'circle')
     
   })
   
   output$costlocation = renderPlot({
     
     ggplot(by_neighborhood ,aes(x= location, y=avg_cost ))+ 
       geom_col(fill = 'steelblue') + 
       coord_flip() +
       labs(x= "Average Cost", y= "Neighborhood", title= "Cost by Neighborhood")+              
       theme(plot.title =element_text(hjust = .5, size= 15)) +theme_classic()
     
   })
   
}