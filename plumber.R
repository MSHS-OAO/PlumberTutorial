#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

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
#library(reshape2)


# DB DSN 
dsn <- "OAO Cloud DB Production"


#' @apiTitle Balanced Scorecards API
#' @apiDescription API for fetching the scorecards data, and processing the scorecards data



#' get the data operational data
#' @param service_input parameter to filter based on service line - format "Service Name"
#' @param month_input parameter to filter based on service line - format "mm-yyyy"
#' @post /get-operational-data
get_ops_data <- function(service_input,month_input,res){
  
  # service_input = "Nursing"
  # month_input = "04-2023"
  
  month <- as.Date(paste0(month_input, "-01"), "%m-%Y-%d")
  format <- "YYYY-MM-DD HH24:MI:SS"
  
  
  conn <- dbConnect(drv = odbc::odbc(),
                    dsn = dsn)
  sr_tbl <- tbl(conn, "SUMMARY_REPO")
  ytd_metrics <- sr_tbl %>% 
    filter(SERVICE %in% service_input,
           TO_DATE(month, format) == REPORTING_MONTH) %>%
    select(-UPDATED_TIME, -UPDATED_USER) %>% collect() %>%
    rename(Service = SERVICE,
           Site = SITE,
           Premier_Reporting_Period = PREMIER_REPORTING_PERIOD,
           value_rounded = VALUE,
           Reporting_Month_Ref = REPORTING_MONTH
    ) %>%
    mutate(Reporting_Month = format(Reporting_Month_Ref, "%m-%Y"))%>% 
    select(-METRIC_NAME_SUBMITTED) %>%
    distinct()
  
  dbDisconnect(conn)
  
  list(ops_data = ytd_metrics)
  
}

#' API status function
#' @get /status
status <- function() {
  list(status = "API is running",
       time = Sys.time())
}


#' Plot a histogram
#' @serializer contentType list(type='image/png')
#' @param service_input parameter to filter based on service line - format "Service Name"
#' @param month_input parameter to filter based on service line - format "mm-yyyy"
#' @get /get_plot
function(service_input,month_input) {

    # service_input = "Nursing"
    # month_input = "04-2023"
    
    month <- as.Date(paste0(month_input, "-01"), "%m-%Y-%d")
    format <- "YYYY-MM-DD HH24:MI:SS"
    
    
    conn <- dbConnect(drv = odbc::odbc(),
                      dsn = dsn)
    sr_tbl <- tbl(conn, "SUMMARY_REPO")
    budget_metrics <- sr_tbl %>% 
      filter(SERVICE %in% service_input,
             TO_DATE(month, format) == REPORTING_MONTH,
             METRIC_NAME_SUBMITTED == "Budget_Total (Monthly)" ) %>%
      select(-UPDATED_TIME, -UPDATED_USER) %>% collect() %>%
      rename(Service = SERVICE,
             Site = SITE,
             Premier_Reporting_Period = PREMIER_REPORTING_PERIOD,
             value_rounded = VALUE,
             Reporting_Month_Ref = REPORTING_MONTH
      ) %>%
      mutate(Reporting_Month = format(Reporting_Month_Ref, "%m-%Y"))%>% 
      select(-METRIC_NAME_SUBMITTED) %>%
      distinct() %>%
      arrange(value_rounded)
    
    dbDisconnect(conn)
    
    graph_bar <- ggplot(budget_metrics, aes(x=reorder(Site, -value_rounded), y=value_rounded)) + 
      geom_bar(stat = "identity") +
      labs(title = paste0("Budget Metrics for ",service_input," for month ",month_input),
           x = "Hospital",
           y ="Budget" )+
      scale_y_continuous(labels=scales::dollar_format())+
      scale_y_continuous(labels = unit_format(unit = "M", scale = 1e-6)) +
      theme_minimal()
    
    filename <- paste0(service_input,month_input,".png")
    ggsave(filename,graph_bar)
    
    #filename <- "Nursing04-2023.png"
    readBin(filename, "raw", n = file.info(filename)$size)
    
    
}



# Programmatically alter your API
#' @plumber
function(pr) {
    pr %>%
        # Overwrite the default serializer to return unboxed JSON
        pr_set_serializer(serializer_unboxed_json())
}


# r <- plumb("plumber.R")
# r$run(host="127.0.0.1",port=8000)
