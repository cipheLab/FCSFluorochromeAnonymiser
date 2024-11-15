# FCSColumnNameEditor
This tool is a Rshiny application that anonymises certain columns in one or more FCS files.

   ## Usage


#### 1 - Download FCSColumnNameEditor ZIP file

#### 2 - Launch App

#### 3 - Load FCS file(s)

#### 4 - Select the lines to be anonymised

#### 5 - Click on the ‘change Names’ button

#### 6 - Download the modified FCS

#### 7 - 


## Requirements

To run this project, you will need several R packages. Here is the list of required packages:

```R
install.packages(c("shiny", "DT","shinythemes","shinybusy","shinydashboard","shinyjs"))
```

```R
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("flowCore")
```
