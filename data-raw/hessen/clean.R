
#basic cleaning, taking remove entries without place and create string for geocoding
chronik %>%
  filter(!is.na(place)) %>%
  dplyr::select(-descr) %>%
  mutate(place = str_remove(place, "\\s\\(.*\\)")) %>%
  mutate(placestring = str_replace_all(place, "\\s", "+")) %>%
  mutate(placestring = paste0(placestring, "+Hessen")) -> chronik_clean

#need improvement: what do when multiple sources? take only first mentioned source?
chronik_clean %>%
  mutate(source_name = str_extract(descr_text, "Quelle.*")) %>%
  mutate(source_name = str_remove(source_name, "Quelle:|Quellen:|Quelle|Quellen")) %>%
  mutate(source_group = case_when(grepl("Hessenschauthin", source_name, ignore.case = T) ~ "Hessenschauthin", 
                                  grepl("Presseportal", source_name, ignore.case = TRUE) ~ "Presseportal",
                                  grepl("Anfrage", source_name, ignore.case = TRUE) ~ "Parlamentarische Anfragen",
                                  grepl("response", source_name, ignore.case = TRUE) ~ "response",
                                  grepl("rundschau|taz|zeitung|allgemeine|anzeiger", source_name, ignore.case = TRUE) ~ "Zeitungen",
                                  TRUE ~ "Andere"
  )) -> chronik_clean


map_chronik <- chronik_clean %>% dplyr::group_by(placestring) %>% dplyr::summarise(n = n()) %>% ungroup
#do the actual geocoding
for (i in 1:length(map_chronik$placestring)) {
  result <- geocode(map_chronik$placestring[i])
  map_chronik$lat[i] <- result$lat
  map_chronik$lon[i] <- result$lon
  map_chronik$admin6[i] <- as.character(result$admin6)
  message(i)
  Sys.sleep(1)
}


#bring lon, lat, admin6 back into original data. not very elegant
chronik_clean %>%
  left_join(dplyr::select(map_chronik, -n), by = c(placestring = "placestring")) -> chronik_enriched
