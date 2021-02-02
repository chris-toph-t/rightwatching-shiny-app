theme_transparent <- function(base_size = 12, base_family = "Helvetica"){
  theme_ipsum() %+replace%
    theme(
      panel.background = element_rect(fill = "transparent", color = NA), # bg of the panel
      plot.background = element_rect(fill = "transparent", color = NA),
      legend.position = "right"
    )
}

make_barchart <- function(data = chronik_enriched, level = month) {
  data %>%
    ggplot(aes_string(x=level)) +
    geom_bar() +
    scale_x_date() +
    theme_ipsum() +
    labs(y = "Anzahl Vorfälle", x = level) 
}

make_county_timeline <- function(data = chronik_by_county, selected_kreise) {
  data %>%
    filter(admin6 %in% selected_kreise) %>%
    ggplot(aes(x=month, y=n, group=admin6)) +
    geom_line() +
    scale_x_date(date_labels = "%b %y") +
    #scale_color_viridis(discrete = TRUE) +
    facet_wrap(~admin6) +
    theme_ipsum() +
    theme(legend.position = "none") +
    labs(x = "Monat", y = "Vorfälle")
  
}

make_source_timeline <- function(data = chronik_by_source_date) {
  data %>% 
    ggplot(aes(x=month, y=n, color=source_group)) +
    geom_line(size = 1) +
    scale_x_date(date_labels = "%b") +
    #scale_color_viridis(discrete = TRUE) +
    labs(x = "Jahr", y = "Vorfälle") + 
    theme_ipsum() +
    theme(legend.position = "bottom") 
}


make_base_map <- function(baselayer = kreise) {
  #to make police map, change default sourcegroup to "Presseportal" or any other grouping of sources as per 04_clean script and adjust label
  ggplot() + 
    geom_sf(data = baselayer, aes(geometry = geometry), fill = "white") +
    #scale_fill_continuous(name = "AfD-Stimmenanteil") +
    coord_sf() + 
    #theme(legend.position = "none") +
    #labs(size = label) + 
    theme_transparent() 
}

make_historic_map <- function(data = historic_filtered) {
  ggplot() +
    geom_sf(data = kreise, aes(geometry = geometry)) +
    stat_summary_hex(data = filter(data, nsdap_percent_33 < 100), aes(x = lon, y = lat, z = nsdap_percent_33), alpha = 0.9, bins = 30, fun = mean) +
    scale_fill_viridis(option = "inferno", direction = -1, name = "NSDAP WählerInnen 1933") +
    #geom_jitter(data = data, aes(x = lon, y = lat, color = source_group, group=source_group), width = 0.05, height = 0.05, size = 0.7) +
    #scale_color_manual(values = c("black", "#1B9E77"), name="Kontaktaufname") +
    #geom_label_repel(data = labels, aes(x = longitude_to, y = latitude_to, label = label), nudge_x = 10) +
    coord_sf() +
    labs(caption = "Wahldaten nach Falter & Hänisch 1990") +
    theme_transparent()
}

make_context_map1 <- function(party = input$context_map_option2) {
    kreise %>%
      left_join(select(
        filter(votes_data, PART04 == party), id, vote_percentage), 
        by = c("AGS_KREIS_ID" = "id")) -> kreise
    
    make_base_map() +
      geom_sf(data = kreise, aes(geometry = geometry, alpha = vote_percentage), fill = "orange") +
      #stat_bin_hex(data = chronik_enriched, aes(x = lon, y = lat, fill = ..count..), alpha = 0.9, binwidth = 0.05) +
      geom_point(data = chronik_by_place(), aes(x = lon, y = lat, size = n), fill = "black", color = "grey20") +
      scale_fill_viridis(option = "cividis", direction = -1) +
      labs(size = "Vorfälle laut Chronik", alpha = paste0(input$context_map_option2, " WählerInnen, %")) +
      theme(legend.position = "right")
}

make_context_map2 <- function () {
  make_base_map(baselayer = kreise) +
    geom_sf(data = pop2011_filtered, aes(alpha = TOT_P), fill = "Blue", lwd=0) +
    stat_bin_hex(data = chronik_filtered(), aes(x = lon, y = lat, fill = ..count..), alpha = 0.8, binwidth = 0.05) +
    scale_fill_viridis(option = "C", name = "Vorfälle laut Chronik", direction = -1) +
    labs(alpha = "Bevölkerungsdichte")
}
make_context_map3 <- function() {
  make_base_map() +
    geom_sf(data = kreise, aes(geometry = geometry, fill = NATA_percentage)) +
    #stat_bin_hex(data = chronik_enriched, aes(x = lon, y = lat, fill = ..count..), alpha = 0.9, binwidth = 0.05) +
    geom_point(data = chronik_by_place(), aes(x = lon, y = lat, size = n), fill = "black", color = "grey20") +
    scale_fill_viridis(option = "cividis", direction = -1) +
    labs(size = "Vorfälle laut Chronik", fill = "% AusländerInnen")
}
make_context_map4 <- function() {
  pt1 <- make_base_map() +
    geom_sf(data = kreise, aes(geometry = geometry)) +
    geom_point(data = chronik_by_place(), aes(x = lon, y = lat, size = n), fill = "black", color = "grey20") +
    labs(size = "Vorfälle rechter Gewalt")
  pt2 <- make_historic_map() 
  
  cowplot::plot_grid(pt1, pt2, align = "h")
}



make_nationality_barchart <- function() {
  ggplot(data = nationality_data, aes(x = 1, y = value, fill = param_description, group = name)) +
    geom_bar(stat = "identity", position = "fill") +
    scale_y_percent() +
    theme_ipsum() +
    facet_wrap(~name) +
    labs(y = "Prozent", x = "Jahr") 

}

make_source_multiple_map <- function() {
  make_base_map(baselayer = kreise) +
    geom_jitter(data = chronik_filtered(), aes(x = lon, y = lat, color = source_group, group=source_group), width = 0.05, height = 0.05, size = 0.7) +
    #scale_color_manual(values = c("black", "#1B9E77"), name="Kontaktaufname") +
    #geom_label_repel(data = labels, aes(x = longitude_to, y = latitude_to, label = label), nudge_x = 10) +
    coord_sf() +
    labs(caption = "Punkte sind hier nicht genau auf dem Ort des Vorfalls") + 
    facet_wrap(~source_group) + 
    theme_transparent() + 
    theme(legend.position = "right")
}

make_source_map <- function() {
  ggplot() +
    geom_sf(data = kreise, aes(geometry = geometry), fill = "grey60") +
    stat_bin_hex(data = chronik_enriched, aes(x = lon, y = lat), alpha = 0.9, binwidth = 0.05) +
    scale_fill_viridis(option = "inferno", direction = -1, name = "Vorfälle in Chronik") +
    geom_point(data = filter(chronik_by_source_place(), source_group == input$source_map_option1), aes(x = lon, y = lat, size = n), fill = "black") +
    coord_sf() +
    labs(size = input$source_map_option1) +
    theme_transparent()	
  
}

