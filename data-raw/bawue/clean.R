
#basic cleaning, taking remove entries without place and create string for geocoding
chronik %>%
  mutate(placestring = str_replace_all(place, "\\s", "+")) %>%
  mutate(placestring = paste0(placestring, "+Baden-Württemberg")) -> chronik_clean

#need improvement: what do when multiple sources? take only first mentioned source?
chronik_clean %>%
  mutate(source_links = str_remove(source_links, "Quelle:\\s{5}")) %>%
  mutate(source_name = str_remove(str_extract(source_links, "//.*?(/|$)"), "(//www.|//)")) %>%
  mutate(source_group = case_when(grepl("rechtsaussen", source_name, ignore.case = T) ~ "rechtsaussen", 
                                  grepl("presseportal", source_name, ignore.case = TRUE) ~ "Presseportal",
                                  grepl("kleineanfrage|bundestag", source_name, ignore.case = TRUE) ~ "Parlamentarische Anfragen",
                                  grepl("leuchtlinie", source_name, ignore.case = TRUE) ~ "leuchtlinie",
                                  grepl("rundschau|taz|zeitung|allgemeine|anzeiger|news|bote|post|chronik|spiegel", source_name, ignore.case = TRUE) ~ "Zeitungen",
                                  TRUE ~ "Andere"
  )) -> chronik_clean


map_chronik <- chronik_clean %>% dplyr::group_by(placestring) %>% 
  dplyr::summarise(n = n()) %>% 
  ungroup %>% 
  add_column(lat = as.numeric(NA)) %>% 
  add_column(lon = as.numeric(NA)) %>% 
  add_column(admin6 = as.character(NA))

#do the actual geocoding
for (i in 1:length(map_chronik$placestring)) {
  result <- geocode(map_chronik$placestring[i])
  map_chronik$lat[i] <- result$lat
  map_chronik$lon[i] <- result$lon
  map_chronik$admin6[i] <- result$admin6
  message(i)
}


#bring lon, lat, admin6 back into original data. not very elegant
chronik_clean %>%
  left_join(select(map_chronik, -n), by = c(placestring = "placestring")) -> chronik_enriched
