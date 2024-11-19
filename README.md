# FCSFluorochromeAnonymiser
This tool is a Rshiny application that anonymises certain columns in one or more FCS files.

   ## Usage


#### 1 - Download FCSFluorochromeAnonymiser ZIP file

![image](https://github.com/user-attachments/assets/af4446c2-98c5-4172-bd9d-1271379ccd23)

#### 2 - In RStudio, open ui.R OR server.R file

#### 3 - Launch App 
![image](https://github.com/user-attachments/assets/02eee245-1028-4fdc-b140-d11271d4247d)

#### 4 - Load FCS file(s)

#### 5 - Click on the lines to be anonymised
![image](https://github.com/user-attachments/assets/9a1212c3-4e86-4d5a-bc00-b7f47f5dda02)

#### 6 - Click on the ‘change Names’ button

#### 7 - Download the modified FCS

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
