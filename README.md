# FCSColumnNameEditor
This tool is a Rshiny application that anonymises certain columns in one or more FCS files.

   ## Usage


#### 1 - Download FCSColumnNameEditor ZIP file

![image](https://github.com/user-attachments/assets/e70d8421-f14d-40cc-963a-f0f25d021d38)

#### 2 - In RStudio, open ui.R OR server.R file

#### 3 - Launch App 
![image](https://github.com/user-attachments/assets/02eee245-1028-4fdc-b140-d11271d4247d)

#### 4 - Load FCS file(s)

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
