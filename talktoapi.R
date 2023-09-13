library(plumber)
library(pool)
library(assertr)
library(readxl)
library(writexl)
library(plyr)
library(dplyr)
library(data.table)
library(zoo)
library(lubridate)
library(tidyverse)
library(ggQC)
library(utils)
library(scales)
library(chron)
library(bupaR)
library(shiny)
library(DT)
library(DiagrammeR)
library(edeaR)
library(processmapR)
library(processmonitR)
library(processanimateR)
library(tidyr)
library(lubridate)
library(RColorBrewer)
library(DiagrammeR)
library(ggplot2)
library(leaflet)
library(readr)
library(broom)
library(tis) # for US holidays
library(vroom)
library(openxlsx)
library(sjmisc)
library(tools)
library(here)
library(fasttime)
library(janitor)
library(stringr)
library(glue)
library(magrittr)
library(DBI)
library(odbc)
library(dbplyr)
library(httr)
library(jsonlite)
#library(reshape2)



res = GET("https://hso-rconnect.mssm.edu/PlumberLearningSession/status")

rawToChar(res$content)
result <- fromJSON(rawToChar(res$content),flatten = TRUE)




get_data <- function(service, month){
  
  
  URL <- "https://hso-rconnect.mssm.edu/PlumberLearningSession//get-operational-data"
  encoded_service <- URLencode(service, reserved = TRUE)
  
  payload <- paste0(URL,"?service_input=",encoded_service,"&month_input=",month)
  
  
  result <- POST(payload)
  data <- rawToChar(result$content)
  data <- fromJSON(data,flatten = TRUE)$ops_data
}


get_plot_budget <- function(service, month){
  
  
  URL <- "https://hso-rconnect.mssm.edu/PlumberLearningSession/get-plot"
  encoded_service <- URLencode(service, reserved = TRUE)
  
  payload <- paste0(URL,"?service_input=",encoded_service,"&month_input=",month)
  
  
  result <- POST(payload,accept(".png"))
  data <- rawToChar(result$content)
  data <- fromJSON(data,flatten = TRUE)$ops_data
}

service <- "Case Management / Social Work"
month <- "04-2023"

data <- get_data(service,month)
#plot <- get_plot_budget()





