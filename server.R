# California Hospital Scores
# Author: Gary Chung
# server.R
# ==========================

# Required libraries
# ------------------
library(shiny)
library(leaflet)
library(RColorBrewer)
library(ggmap)

# Server code
# -----------
shinyServer(function(input, output, session) {
  
  values <- reactiveValues(where = "Los Angeles")
  
  observe({
    if(input$submit > 0) {
      values$where <- isolate(input$where)
    }
  })
  
  output$CAmap <- renderLeaflet({
    load(file="Data/aSet.Rdata")
    currLoc <- geocode(values$where)
    # Set the red-green color palette
    pal <- colorNumeric(palette = c("#FF0000", "#00FF00"), 
                        domain = aSet.all$Color.Rate)
    # Set the pop-up message
    content <- paste(sep="<br/>",
                     ~Hospital,
                     paste("Score:", ~Rate.Norm))
    # Create the map
    leaflet(aSet.all) %>% setView(currLoc$lon, currLoc$lat, zoom=12) %>%
      addProviderTiles("Stamen.TonerLite") %>%
      addCircles(weight = 1,
                 radius = ~circle.radius, 
                 fillOpacity = 0.7,
                 popup = ~paste("<b>", Hospital, "</b><br/>",
                                paste("Score:", round(Rate.Norm, 0)), "<br/>",
                                paste("Procedures Done:", Num.Cases)),
                 color = ~pal(Color.Rate)
      )
  })  
})
