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
library(httr2)
library(curl)
library(jsonlite)
library(gsubfn)
#library(reshape2)




check_api <- function(){
  
  res = request("https://hso-rconnect.mssm.edu/PlumberLearningSession/status") %>%
    req_method("GET") %>%
    req_perform()
  
  result <- fromJSON(rawToChar(res$body),flatten = TRUE)$status
  
  result
  
  
}


get_data <- function(service, month){
  
  
  URL <- "https://hso-rconnect.mssm.edu/PlumberLearningSession/get-operational-data"
  encoded_service <- URLencode(service, reserved = TRUE)
  
  payload <- paste0(URL,"?service_input=",encoded_service,"&month_input=",month)
  
  result <- request(payload) %>%
    req_method("POST") %>%
    req_perform()
  
  data <- rawToChar(result$body)
  data <- fromJSON(data,flatten = TRUE)$ops_data
}


get_plot_budget <- function(service, month){
  
  
  URL <- "https://hso-rconnect.mssm.edu/PlumberLearningSession/get_plot"
  encoded_service <- URLencode(service, reserved = TRUE)
  payload <- paste0(URL,"?service_input=",encoded_service,"&month_input=",month)
  filename = paste0(gsub(" ", "",gsub("/","",service)),month,".png")
  download.file(payload, filename, mode = "wb")
  

}


check_api()

service <- "Case Management / Social Work"
month <- "04-2023"




data <- get_data(service,month)
plot <- get_plot_budget(service,month)

