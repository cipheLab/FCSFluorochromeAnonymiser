# FCSColumnNameEditor
This tool is a Rshiny application that anonymises certain columns in one or more FCS files.

   ## Usage

### 1 - Load FCS file(s)
### 2 - Select the lines to be anonymised
### 3 - Click on the ‘change Names’ button
### 4 - Download the modified FCS


## Requirements

To run this project, you will need several R packages. Here is the list of required packages:

```R
install.packages(c("shiny", "flowCore", "DT","shinythemes","shinybusy","shinydashboard","shinyjs"))
