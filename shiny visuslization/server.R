
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
   
   output$review = renderTable({
            
           t(rest_reviews()%>% distinct(rest_name,review_count,rating, additional_info) %>%select(review_count,rating, additional_info))
                 
            #ggplot(by_review, aes(x=rest_name, y=review_count))+ 
                # geom_col( fill = "darkgreen")+
                # theme_bw() + 
            #labs(x= "Restaurants", y= "reviews", title= "Restaurants by ReviewCounts")+              theme(plot.title =element_text(hjust = .5, size= 10) , 
               #axis.text.x = element_text(angle=90, vjust=0.5))
     
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
     value = (rest_reviews()$review_count)
     
     infoBox(tags$p("Review Count", style = "font-size: 80%;"), value, color= "aqua", fill= TRUE)
   })
   
   output$revrating <- renderInfoBox({
     value = rest_reviews()$rating
     infoBox("rating", value, color= "aqua", fill= TRUE)
   })
   
   
   output$reviewcloud = renderWordcloud2({
     review_corpus=Corpus(VectorSource(rest_reviews()$review))
     
     #remove punctuation
     review_corpus = tm_map(review_corpus, removePunctuation)
     
     ## remove numbers
     review_corpus = tm_map(review_corpus, removeNumbers)
     
     ## LowerCase
     review_corpus = tm_map(review_corpus, tolower)
     
     words_to_remove=c('york', 'com', 'read', 'nyc', 'read', 'full', 'york', 'restaurant', 'just', 'pig', 'will', 'can', 'much', 'post', 'new','just', 'katz', 'katzs','nobu', 'candle', 'came', 'went','also','sandwiches', 'korean', 'well', 'danny','madison', 'park', 'eleven', 'katz', 'went','place','burgers','about','know','many','see','one','union', 'ever','restaurants','sandwiches', 'cant', 'joey','yet', 'ajisen','shack')
     
     review_corpus = tm_map(review_corpus, removeWords, c(stopwords("english"),words_to_remove))
     
     
     ## turn into doc matrix
     reviews_dtm = DocumentTermMatrix(review_corpus)
     reviews_dtm = as.matrix(reviews_dtm)
     
     
     # displaying most frequent words
     freq= data.frame(Words = colnames(reviews_dtm), 
                      Freq = colSums(reviews_dtm), 
                      row.names = NULL)
     freq = freq[order(-freq$Freq),]
     
     
      wordcloud2(freq, size =0.5, shape = 'circle')
     
   })
  
   output$costlocation = renderGvis({
      
     gvisAreaChart(by_neighborhood ,
          options= list(vAxes="[{title:'Cost($)'}]",
                         hAxes = "[{title:'Neighborhood'}]",
                        title="Cost by Neighborhood", 
                        legend="none",
                        height=400))
    
  })
  
}