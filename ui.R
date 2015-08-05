# California Hospital Scores
# Author: Gary Chung
# ui.R
# ==========================

library(shiny)
library(leaflet)

shinyUI(fluidPage(theme = "bootstrap.css",
  
  # Application Title
  titlePanel(h1("Best & Worst Hospitals Near You")),
  
  # Search Bar
  fluidRow(
    column(12, 
           h4("Where do you live?"),
           textInput("where", label=NULL, value="Los Angeles"),
           actionButton("submit", "Submit"),
           br(), br()
           
           )),
  
  # The Map
  leafletOutput("CAmap", height=700),
  
  # References
  fluidRow(
    column(12,
           h2("What is a Good Score?"),
           p(strong("50 is an average score."), br(),
             "A ", strong("high"), " score is 85 or more. Only 15% of hospitals
             are in this category.", br(),
             "A ", strong("low"), " score is 15 or less. 15% of hospitals are 
             in this category.", br(),
             "The ", strong("top"), " score is 95.",
             "The ", strong("lowest"), " scores can even be negative!"),
           h2("What do the Circle Sizes Mean?"),
           p("The bigger the circle, the more procedures done at that 
             hospital."),
           h2("About the Scores"),
           p("Scores are based on 2011-2013 risk-adjusted mortality rates for 
             the following surgical procedures:"),
           tags$ul(
             tags$li("AAA Repair"), 
             tags$li("Acute Stroke"), 
             tags$li("Acute Stroke Hemorrhagic"),
             tags$li("Acute Stroke Ischemic"),
             tags$li("Acute Stroke Subarachnoid"),
             tags$li("AMI"),
             tags$li("Carotid Endarterectomy"),
             tags$li("Craniotomy"),
             tags$li("Esophageal Resection"),
             tags$li("GI Hemorrhage"),
             tags$li("Heart Failure"),
             tags$li("Hip Fracture"),
             tags$li("Pancreatic Cancer"),
             tags$li("Pancreatic Other"),
             tags$li("Pancreatic Resection"),
             tags$li("PCI"),
             tags$li("Pneumonia")),
           h3("Credits and Attribution"),
           span("Data Provided by ", a("CHHS", href="https://chhs.data.ca.gov")),
           br(),
           span("Analysis and Application Developed by ", 
                a("Gary Chung", href="http://gary-chung.com")),
           br(),
           span(a("Git", href="https://github.com/gunkadoodah/CAhospitals"))
           ))
  
))
