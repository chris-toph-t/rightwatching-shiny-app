#' summarising all data files into handy formats for visualization
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import dplyr
#' 


  
  
chronik_by_source_place <- reactive(
  chronik_filtered() %>%
    group_by(source_group, city, longitude, latitude) %>%
    summarise(n = n()) %>% 
    ungroup() %>% 
    unnest(city)  
)
chronik_by_county <- reactive(
  chronik_filtered() %>%
    group_by(county, month) %>%
    summarise(n= n())   
)
 
chronik_by_source_date <- reactive(
  chronik_filtered() %>% 
    group_by(month, source_group) %>% 
    summarise(n = n())   
)
 

chronik_by_place <- reactive(
  chronik_filtered() %>%
    group_by(city, longitude, latitude) %>%
    summarise(n = n())   
)
