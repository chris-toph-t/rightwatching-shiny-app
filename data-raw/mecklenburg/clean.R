
#basic cleaning, taking remove entries without place and create string for geocoding
chronik %>%
  mutate(placestring = str_replace_all(place, "\\s", "+")) %>%
  mutate(placestring = paste0(placestring, "+Mecklenburg-Vorpommern")) -> chronik_clean

#need improvement: what do when multiple sources? take only first mentioned source?
chronik_clean %>%
  mutate(source_name = str_remove(sources, "Quelle:\\s*\\n\\s*")) %>%
  tidyr::separate(sources, sep = ", ", into = c("source_1", "source_2", "source_3", "source_4", "source_5"), remove = FALSE)  %>%
  mutate(source_group = case_when(grepl("antifa|endstation", source_1, ignore.case = T) ~ "SzenebeobachterInnen", 
                                  grepl("polizei", source_1, ignore.case = TRUE) ~ "Polizei",
                                  grepl("lobbi", source_1, ignore.case = TRUE) ~ "LOBBI",
                                  grepl("nachrichten|kurier|zeitung|ticker|dpa|abendblatt|redaktion|reporter", source_1, ignore.case = TRUE) ~ "Zeitungen",
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
}


#bring lon, lat, admin6 back into original data. not very elegant
chronik_clean %>%
  left_join(select(map_chronik, -n), by = c(placestring = "placestring")) -> chronik_enriched
