library(shiny)
library(flowCore)
library(DT)

server <- function(input, output) {
  listObject <- reactiveValues(
    dataList = NULL,
    selected_rows = NULL)
  
  fixUploadedFilesNames <- function(x) {
    if (is.null(x)) return()
    
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
    if (is.null(inFiles)) return(NULL)
    
    dataList <- lapply(inFiles$datapath, read.FCS)
    names(dataList) <- inFiles$datapath
    fcsDataList(dataList)
  })
  
  # Output the interactive table with row selection
  output$table <- renderDT({
    dataList <- fcsDataList()
    if (is.null(dataList) || length(dataList) == 0) return(data.frame())
    
    data <- dataList[[1]]
    colnames_table <- colnames(exprs(data))
    data.frame(Column = colnames_table, stringsAsFactors = FALSE)
  }, editable = TRUE, selection = 'multiple', options = list(pageLength = 100, scrollX = TRUE))
  
  observeEvent(input$table_rows_selected, {
    selected_rows <- input$table_rows_selected
    dataList <- fcsDataList()
    
    if (length(dataList) == 0 || length(selected_rows) == 0) return()
    
    listObject$dataList <- dataList
    listObject$selected_rows <- selected_rows
  })
  
  # Helper function to generate variable names beyond Z (AA, AB, etc.)
  generateColumnNames <- function(n) {
    base <- LETTERS
    if (n <= length(base)) return(base[1:n])
    
    # For names beyond 'Z' (e.g., 'AA', 'AB', ...)
    extended <- c()
    for (i in 1:ceiling(n / length(base))) {
      extended <- c(extended, paste0(rep(base[i], length(base)), base))
    }
    return(extended[1:n])
  }
  
  observeEvent(input$changeNames, {
    for (i in seq_along(listObject$dataList)) {
      data <- listObject$dataList[[i]]
      selected <- listObject$selected_rows
      new_names <- generateColumnNames(length(selected))
      
      old_column_names <- colnames(data)[selected]
      colnames(data)[selected] <- new_names
      
      # Update SPILL or SPILLOVER if present
      for (spill_key in c("SPILL", "$SPILLOVER")) {
        if (spill_key %in% names(data@description)) {
          target_matrix <- data@description[[spill_key]]
          for (j in seq_along(old_column_names)) {
            old_name <- old_column_names[j]
            new_name <- new_names[j]
            if (old_name %in% colnames(target_matrix)) {
              colnames(target_matrix)[colnames(target_matrix) == old_name] <- new_name
              data@description[[spill_key]] <- target_matrix
            }
          }
        }
      }
      listObject$dataList[[i]] <- data
    }
    fcsDataList(listObject$dataList)
    showNotification("Les colonnes sélectionnées ont été mises à jour.", type = "message")
  })
  
  observeEvent(input$downloadData, {
    showModal(modalDialog(
      title = "Export anonymized FCS  ",
      tags$div(
        style = "text-align: center;",
        tags$p("Please wait.")
      ),
      footer = NULL,
      easyClose = FALSE
    ))
    for (i in seq_along(listObject$dataList)) {
      file_name <- basename(names(listObject$dataList)[[i]])
      write.FCS(listObject$dataList[[i]], file.path(getwd(), paste0("modified_", file_name)))
    }

   
    removeModal()
  })
}
