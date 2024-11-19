library(shiny)
library(DT) 
library(shinydashboard)
library(shinyjs)
library(shinybusy)
library(flowCore)
library(shinythemes)

ui <- dashboardPage(
  dashboardHeader(title = "FCS Anonymiser"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Help", tabName = "help", icon = icon("question")),
      menuItem("Upload", tabName = "upload", icon = icon("upload"))
    ),
    
  actionButton('downloadData', 'Download Modified File', 
                   style = "margin-top: 20px;")
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .info-text {
          color: red; 
          font-style: italic;
          margin-bottom: 20px;
        }
        .custom-header {
          text-align: center;
          margin-bottom: 20px;
        }
      "))
    ),
    
    tabItems(
      tabItem(tabName = "upload",
              fluidRow(
                column(12,
                       tags$h3("Please ensure that all uploaded FCS files have the same column names!", 
                               class = "info-text"),
                       tags$hr(),  # Horizontal line for better separation
                       fileInput('file1', 'Choose FCS File', 
                                 accept = c('.fcs'), multiple = TRUE),
                       tags$br(),  # Line break for spacing
                       actionButton("changeNames", "Anonymise", 
                                    class = "btn btn-primary")  # Button with styling
                ),
                column(12, DTOutput('table'),  # Display the interactive table
                       tags$br(),  # Line break for spacing
                       tags$div(id = "status_message")  # Placeholder for status messages
                )
              )
      ),
      tabItem(tabName = "help",
              h2("This tool is a R Shiny application that anonymizes fluorochromes in one or more FCS files."),
              h3("Instructions:"),
              tags$ol(
                tags$li("Load FCS file(s)"),
                tags$li("Select lines to be anonymized"),
                tags$li("Click on the ‘Anonymise’ button"),
                tags$li("Download the modified FCS file")
              )
      )
    )
  )
)
