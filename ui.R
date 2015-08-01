# California Hospital Scores
# Author: Gary Chung
# ui.R
# ==========================

library(shiny)
library(leaflet)

shinyUI(fluidPage(
  
  # Application Title
  titlePanel("Best & Worst Hospitals Near You"),
  
  # Search Bar
  fluidRow(
    column(12, 
           textInput("where", label="Where do you live?", value=NULL),
           actionButton("submit", "Submit"),
           br(), br()
           
           )),
  
  # The Map
  leafletOutput("CAmap", height=700)
  
))
