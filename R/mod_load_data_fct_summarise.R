#' @importFrom  dplyr summarise

chronik_by_source_place <- reactive(
  chronik_filtered() %>%
    group_by(source_group, place, lon, lat) %>%
    summarise(n = n()) %>% 
    ungroup() %>% 
    unnest(place)  
)

chronik_by_county <- reactive(
  chronik_filtered() %>%
    group_by(admin6, month) %>%
    summarise(n= n())   
)

chronik_by_source_date <- reactive(
  chronik_filtered() %>% 
    group_by(month, source_group) %>% 
    summarise(n = n())   
)

chronik_by_place <- reactive(
  chronik_filtered() %>%
    group_by(place, lon, lat) %>%
    summarise(n = n())   
)


