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
    print(selected_rows)  # Debugging line
    
    dataList <- fcsDataList()
    if (length(dataList) == 0 || length(selected_rows) == 0) return()
    listObject$dataList<-dataList
    listObject$selected_rows<-selected_rows
  })

  observeEvent(input$changeNames, {

        for (i in seq_along(listObject$dataList)) {
          data <- listObject$dataList[[i]]
          print(i)
          for (j in seq_along(listObject$selected_rows)) {
            print(j)  # Debugging line
            print(listObject$selected_rows[j])  # Check which row is being processed
            old_column_name <- colnames(data)[listObject$selected_rows[j]]
            new_column_name <- LETTERS[j] 
            print(new_column_name)
            colnames(data)[listObject$selected_rows[j]] <- new_column_name
          }
          listObject$dataList[[i]] <- data  # Update the data in the list
        }
        fcsDataList(listObject$dataList)  # Update the fcsDataList
        showNotification("Les colonnes sélectionnées ont été mises à jour.", type = "message")
  
  })
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("updated_files", Sys.Date(), ".zip", sep = "")
    },
    content = function(zip_file) {
      dataList <- fcsDataList()
      if (is.null(dataList) || length(dataList) == 0) {
        return(NULL)
      }
      
      files <- sapply(seq_along(dataList), function(i) {
        file_name <- basename(names(dataList)[[i]])
        write.FCS(dataList[[i]], file_name)
        file_name
      })
      
      zip(zip_file, files, flags = '-r9Xj')
      sapply(files, unlink)
    },
    contentType = "application/zip"
  )
}


