library(shiny)
library(flowCore)
library(DT)

server <- function(input, output) {
  listObject <- reactiveValues(
    dataList = NULL,
    selected_rows=NULL)
  
  
  fixUploadedFilesNames <- function(x) {
    if (is.null(x)) {
      return()
    }
    
    oldNames = x$datapath
    newNames = file.path(dirname(x$datapath), x$name)
    file.rename(from = oldNames, to = newNames)
    x$datapath <- newNames
    x
  }
  
  options(shiny.maxRequestSize = 10000000000 * 1024^2)
  
  fcsDataList <- reactiveVal(list())
  
  observe({
    inFiles <- fixUploadedFilesNames(input$file1)
    if (is.null(inFiles)) {
      return(NULL)
    }
    
    dataList <- lapply(inFiles$datapath, read.FCS)
    names(dataList) <- inFiles$datapath
    fcsDataList(dataList)
  })
  
  # Output the interactive table with row selection
  output$table <- renderDT({
    dataList <- fcsDataList()
    if (is.null(dataList) || length(dataList) == 0) {
      return(data.frame())
    }
    data <- dataList[[1]]
    colnames_table <- colnames(exprs(data))
    data.frame(Column = colnames_table, stringsAsFactors = FALSE)
  }, editable = TRUE, selection = 'multiple', options = list(pageLength = 100, scrollX = TRUE))
  
  observeEvent(input$table_rows_selected, {
    info <- input$table_rows_selected
    selected_rows <- input$table_rows_selected

    
    dataList <- fcsDataList()
    if (length(dataList) == 0 || length(selected_rows) == 0) return()
    listObject$dataList<-dataList
    listObject$selected_rows<-selected_rows
  })
  
  observeEvent(input$changeNames, {
    
    for (i in seq_along(listObject$dataList)) {
      data <- listObject$dataList[[i]]

      for (j in seq_along(listObject$selected_rows)) {
    
        old_column_name <- colnames(data)[listObject$selected_rows[j]]
        new_column_name <- LETTERS[j] 
      
        colnames(data)[listObject$selected_rows[j]] <- new_column_name
      }
      listObject$dataList[[i]] <- data  # Update the data in the list
    }
    fcsDataList(listObject$dataList)  # Update the fcsDataList
    showNotification("Les colonnes sélectionnées ont été mises à jour.", type = "message")
    
  })
  observeEvent(input$downloadData,{

    for (i in seq_along(listObject$dataList)) {
        file_name <- basename(names(listObject$dataList)[[i]])
        print(paste0("files download :", getwd()))
        write.FCS(listObject$dataList[[i]], paste0(getwd(),"/modified_",file_name))

      }

  })
}
