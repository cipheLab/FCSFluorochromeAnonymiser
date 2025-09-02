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


server <- function(input, output, session) {
  listObject <- reactiveValues(
    dataList = NULL,
    selected_rows = NULL
  )
  
  fcsDataList <- reactiveVal(list())
  
  # --- Fix uploaded file names ---
  fixUploadedFilesNames <- function(x) {
    if (is.null(x)) return(NULL)
    oldNames <- x$datapath
    newNames <- file.path(dirname(x$datapath), x$name)
    tryCatch(file.rename(oldNames, newNames), error = function(e) NULL)
    x$datapath <- newNames
    x
  }
  
  options(shiny.maxRequestSize = 10000000000 * 1024^2)
  
  # --- Load FCS files ---
  observe({
    inFiles <- fixUploadedFilesNames(input$file1)
    if (is.null(inFiles)) return(NULL)
    
    dataList <- lapply(inFiles$datapath, function(fp) {
      tryCatch({
        read.FCS(fp, transformation = FALSE, truncate_max_range = FALSE)
      }, error = function(e) {
        showNotification(paste("Error reading:", basename(fp)), type = "error")
        NULL
      })
    })
    
    valid_idx <- !sapply(dataList, is.null)
    dataList <- dataList[valid_idx]
    names(dataList) <- inFiles$name[valid_idx]
    fcsDataList(dataList)
  })
  
  output$table <- DT::renderDT({
    dataList <- fcsDataList()
    if (is.null(dataList) || length(dataList) == 0) return(data.frame())
    data <- dataList[[1]]
    data.frame(Column = colnames(exprs(data)), stringsAsFactors = FALSE)
  })
  
  observeEvent(input$table_rows_selected, {
    selected_rows <- input$table_rows_selected
    dataList <- fcsDataList()
    if (length(dataList) == 0 || length(selected_rows) == 0) return()
    listObject$dataList <- dataList
    listObject$selected_rows <- selected_rows
  })
  
  # --- Rename columns and update spillover ---
  observeEvent(input$changeNames, {
    shinyjs::show("spinner")
    on.exit(shinyjs::hide("spinner"))
    
    for (i in seq_along(listObject$dataList)) {
      data <- listObject$dataList[[i]]
      
      for (j in seq_along(listObject$selected_rows)) {
        old_col <- colnames(data)[listObject$selected_rows[j]]
        new_col <- LETTERS[j]
        
        colnames(data)[listObject$selected_rows[j]] <- new_col
        
        for (spill_key in c("SPILL", "$SPILLOVER")) {
          spill_val <- data@description[[spill_key]]
          if (!is.null(spill_val)) {
            spill_val <- tryCatch({
              if (is.character(spill_val)) flowCore::txt2spillmatrix(spill_val) else spill_val
            }, error = function(e) NULL)
            
            if (!is.null(spill_val) && is.matrix(spill_val)) {
              if (old_col %in% colnames(spill_val)) colnames(spill_val)[colnames(spill_val) == old_col] <- new_col
              if (old_col %in% rownames(spill_val)) rownames(spill_val)[rownames(spill_val) == old_col] <- new_col
              data@description[[spill_key]] <- spill_val
            }
          }
        }
      }
      
      listObject$dataList[[i]] <- data
    }
    
    fcsDataList(listObject$dataList)
    showNotification("✅ Columns and SPILLOVER updated successfully.", type = "message")
  })
  
  # --- One-click download (choose folder and save ZIP) ---
  
  volumes <- c(Home = fs::path_home(), "C:" = "C:/", "D:" = "D:/")
  shinyDirChoose(input, "export_dir", roots = volumes, session = session)
  
  output$downloadData <- renderUI({
    actionButton("export_btn", "Download ZIP", class = "btn btn-success")
  })
  
  observeEvent(input$export_btn, {
    # ask for folder
    showModal(modalDialog(
      title = "Choose export folder",
      shinyDirButton("export_dir", "Select Folder", "Choose a folder"),
      easyClose = TRUE,
      footer = NULL
    ))
  })
  observeEvent(input$export_dir, {
    export_dir <- parseDirPath(volumes, input$export_dir)
    req(export_dir)
    
    dataList <- fcsDataList()
    if (is.null(dataList) || length(dataList) == 0) {
      showNotification("❌ No data to export", type = "error")
      return()
    }
    
    # Keep a local variable for the final path so we can message after the progress closes
    zip_path <- file.path(export_dir, paste0("updated_files_", Sys.Date(), ".zip"))
    
    withProgress(message = "Exporting files… please wait", value = 0, {
      # Allocate ~80% of the bar to writing files, ~20% to zipping
      write_budget <- 0.80
      n <- length(dataList)
      step <- if (n > 0) write_budget / n else write_budget
      
      # Temp dir for files before zipping
      tmpd <- tempfile("fcs_export_")
      dir.create(tmpd)
      
      files <- character(0)
      
      for (i in seq_along(dataList)) {
        file_name <- basename(names(dataList)[[i]])
        f_path <- file.path(tmpd, file_name)
        
        # Update detail + progress for each file
        setProgress(value = (i - 1) * step, detail = sprintf("Writing file %d/%d: %s", i, n, file_name))
        
        tryCatch({
          write.FCS(dataList[[i]], f_path)
          files <- c(files, f_path)
        }, error = function(e) {
          showNotification(sprintf("Failed to write %s: %s", file_name, e$message), type = "error")
        })
        
        incProgress(step)
      }
      
      # Zipping (we can’t get true per-file progress here, so show a single step)
      setProgress(value = write_budget, detail = "Creating ZIP…")
      # Use zip::zipr so we don’t need to setwd()
      zip::zipr(zipfile = zip_path, files = files, root = tmpd)
      
      # Finish
      setProgress(1, detail = "Done")
      unlink(tmpd, recursive = TRUE)
    })
    
    showNotification(paste("✅ File saved to:", zip_path), type = "message")
  })
  
  
}

