library(shiny)
library(DT) 
library(shinydashboard)
library(shinyjs)
library(shinybusy)
library(flowCore)
library(shiny)
library(shinythemes)

ui <- fluidPage(
  theme = shinytheme("flatly"),  # Applying a theme
  
  titlePanel("FCS Fluorochrome Anonymiser", windowTitle = "FCS Anonymiser"),
  
  tags$head(
    tags$style(HTML("
      .info-text {
        color: red; 
        font-style: italic;
        margin-bottom: 20px;
      }
    "))
  ),
  
  fluidRow(
    column(12,
           tags$h4("Please make sure that all the uploaded FCS files have the same column names!", 
                   class = "info-text")
    )
  ),
  
  sidebarLayout(
    sidebarPanel(
      fileInput('file1', 'Choose FCS File', accept = c('.fcs'), multiple = TRUE),
      actionButton('downloadData', 'Download Modified File'),

    ),
    mainPanel(
      DTOutput('table')  ,# Display the interactive table
      actionButton("changeNames", "Change names"),
    )
  )
)
