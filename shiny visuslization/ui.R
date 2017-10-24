library(shiny)
library(ggplot2)
library(leaflet)
library (dplyr)

fluidPage(
  tags$head(tags$style(HTML('.info-box {min-height: 20px;} .info-box-icon {height: 20px; line-height: 30px;} .info-box-content {padding-top: 0px; padding-bottom: 0px;}'))),
            # Add CSS files
            includeCSS(path = "AdminLTE.css"),
            includeCSS(path = "shinydashboard.css"),
             br(),
          navbarPage("NYC Restauarnts",
            tabPanel("Cuisine",
                      selectInput(inputId='cuisine', 
                                  label= 'Cuisine', 
                              choices= unique(restaurants_cuisine$cuisine)),
                      
                      fluidRow(
                              column(4, 
                                  leafletOutput("restaurant_map", height=600)),
                               column(6, 
                                      fluidRow(plotOutput("rating")))),
                     fluidRow(
                       column(8, 
                              plotOutput("averagecost", height=300)))),
             tabPanel("Location",
                      fluidRow(
                        column(10,
                               htmlOutput("costlocation"))),
                      fluidRow(
                                column(10,
                                plotOutput("ratingcost")))),
             tabPanel("Reviews",
                      selectInput(inputId='restaurant', 
                                  label= 'Restaurant', 
                                  choices= unique(restaurants_cuisine$restaurant_name)),
                      fluidRow(column(8,wordcloud2Output("reviewcloud")),
                               column(4,infoBoxOutput("reviewcount", width= 7),
                                     (infoBoxOutput("revrating", width = 7)))))
                       
             )
        )
  
    
          
    
  

  
