
library(shiny)
library(flowCore)
library(DT)
library(shinycssloaders)  
library(shinyFiles)
library(zip)
library(shinyjs)
library(shinybusy)
library(shinydashboard)
library(shinythemes)

ui <- dashboardPage(
  dashboardHeader(title = "FCS Anonymiser"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Help", tabName = "help", icon = icon("question")),
      menuItem("Upload", tabName = "upload", icon = icon("upload"))
    ),
    uiOutput("downloadData")
  ),
  
  dashboardBody(
    useShinyjs(),
    add_busy_spinner(spin = "fading-circle", color = "#3498db", position = "top-right", margins = c(20, 20)),
    
    tabItems(
      tabItem(tabName = "upload",
              fluidRow(
                column(12,
                       tags$h3("Please ensure that all uploaded FCS files have the same column names!", 
                               style = "color:red; font-style:italic; margin-bottom:20px;"),
                       tags$hr(),  
                       fileInput('file1', 'Choose FCS File', accept = c('.fcs'), multiple = TRUE),
                       tags$br(),  
                       actionButton("changeNames", "Anonymise", class = "btn btn-primary")  
                ),
                
                column(
                  12,
                  shinycssloaders::withSpinner(DT::DTOutput('table'), color = "#3498db"),
                  tags$br(),
                  tags$div(id = "status_message")
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
                tags$li("Click on 'Download ZIP' to save the modified files")
              )
      )
    )
  )
)
