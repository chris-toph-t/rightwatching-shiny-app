theme_transparent <- function(base_size = 12, base_family = "Helvetica"){
  theme_void() %+replace%
    theme(
      panel.background = element_rect(fill = "transparent", color = NA), # bg of the panel
      plot.background = element_rect(fill = "transparent", color = NA),
      legend.position = "bottom"
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

# 
# make_population_map <- function(data = chronik_enriched) {
#   #make map with boundaries of counties, population density, all incidents overlaid and county labels
#   ggplot() + 
#     geom_sf(data = kreise, aes(geometry = geometry)) +
#     geom_sf(data = pop2011_filtered, aes(alpha = TOT_P), fill = "#000000", lwd=0) +
#     scale_alpha(name = "Bevölkerungsdichte") +
#     stat_bin_hex(data = data, aes(x = lon, y = lat, fill = ..count..), alpha = 0.9, binwidth = 0.05) +
#     scale_fill_viridis(option = "inferno", direction = -1, name = "Vorfälle laut Chronik") +
#     geom_text_repel(data = kreise, aes(geometry = geometry, label = NAME_LATN), stat = "sf_coordinates", size = 4, color = "grey30") +
#     coord_sf() + 
#     theme_transparent()
#   
# }


# make_source_map <- function(data = chronik_by_source_place, sourcegroup = "Hessenschauthin", label = "Vorfälle aus internen Quellen") {
# #to make police map, change default sourcegroup to "Presseportal" or any other grouping of sources as per 04_clean script and adjust label
#   ggplot() + 
#     geom_sf(data = kreise, aes(geometry = geometry), fill = "grey60") +
#     stat_bin_hex(data = data, aes(x = lon, y = lat), alpha = 0.9, binwidth = 0.05) +
#     scale_fill_viridis(option = "inferno", direction = -1, name = "Vorfälle in Chronik") +
#     geom_point(data = filter(data, source_group == sourcegroup), aes(x = lon, y = lat, size = n), fill = "black") +
#     #scale_color_manual(values = c("black", "#1B9E77"), name="Kontaktaufname") +
#     #geom_label_repel(data = labels, aes(x = longitude_to, y = latitude_to, label = label), nudge_x = 10) +
#     coord_sf() + 
#     #theme(legend.position = "none") +
#     labs(size = label) + 
#     theme_transparent() 
# }




make_context_map <- function(baselayer = kreise) {
  #to make police map, change default sourcegroup to "Presseportal" or any other grouping of sources as per 04_clean script and adjust label
  ggplot() + 
    geom_sf(data = baselayer, aes(geometry = geometry), fill = "white") +
    #scale_fill_continuous(name = "AfD-Stimmenanteil") +
    coord_sf() + 
    #theme(legend.position = "none") +
    #labs(size = label) + 
    theme_transparent() 
}

# 
# make_election_map <- function(data = kreise) {
#   #to make police map, change default sourcegroup to "Presseportal" or any other grouping of sources as per 04_clean script and adjust label
#   ggplot() + 
#     geom_sf(data = data, aes(geometry = geometry, fill = vote_percentage)) +
#     scale_fill_continuous(name = "AfD-Stimmenanteil") +
#     coord_sf() + 
#     #theme(legend.position = "none") +
#     #labs(size = label) + 
#     theme_transparent() 
# }

# make_source_multiple <- function(data = chronik_enriched) {
# #make small multiple map per each source group with jittered dots for each incident
  # ggplot() +
  #   geom_sf(data = kreise, aes(geometry = geometry)) +
  #   #stat_bin_hex(data = opferdata_filtered, aes(x = lon, y = lat), alpha = 0.7, bins = 20) +
  #   #scale_fill_viridis(option = "inferno", direction = -1, name = "Vorfälle laut Chronik") +
  #   geom_jitter(data = data, aes(x = lon, y = lat, color = source_group, group=source_group), width = 0.05, height = 0.05, size = 0.7) +
  #   #scale_color_manual(values = c("black", "#1B9E77"), name="Kontaktaufname") +
  #   #geom_label_repel(data = labels, aes(x = longitude_to, y = latitude_to, label = label), nudge_x = 10) +
  #   coord_sf() +
  #   labs(title = "Polizeimeldungen und andere Quellen decken Hessen ab", caption = "Punkte sind hier nicht genau auf dem Ort des Vorfalls") +
  #   facet_wrap(~source_group, nrow = 1) +
  #   theme_transparent()
# }


make_nationality_barchart <- function() {
  ggplot(data = nationality_data, aes(x = 1, y = value, fill = param_description, group = name)) +
    geom_bar(stat = "identity", position = "fill") +
    scale_y_percent() +
    theme_ipsum() +
    facet_wrap(~name) +
    labs(y = "Prozent", x = "Jahr") 

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

