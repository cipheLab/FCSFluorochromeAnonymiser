# FCSColumnNameEditor
This tool is a Rshiny application that anonymises certain columns in one or more FCS files.

   ## Usage

#### 1 - Launch App
#### 2 - Load FCS file(s)
#### 3 - Select the lines to be anonymised
#### 4 - Click on the ‘change Names’ button
#### 5 - Download the modified FCS


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
