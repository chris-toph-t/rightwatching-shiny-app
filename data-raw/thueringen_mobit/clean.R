
#basic cleaning, taking remove entries without place and create string for geocoding
chronik %>%
  mutate(placestring = str_replace_all(place, "\\s", "+")) %>%
  mutate(placestring = paste0(placestring, "+Thüringen")) -> chronik_clean

#need improvement: what do when multiple sources? take only first mentioned source?
chronik_clean %>%
  mutate(source = str_remove(source, "Quelle:\\s*")) %>%
  mutate(source_group = case_when(grepl("augenzeug", source, ignore.case = T) ~ "Augenzeugen",
                                  grepl("mobit", source, ignore.case = TRUE) ~ "MOBIT",
                                  grepl("ezra", source, ignore.case = TRUE) ~ "EZRA",
                                  grepl("polizei|lfv|verfassungsschutz", source, ignore.case = TRUE) ~ "Polizei/LfV",
                                  grepl("TA|TLZ|OTZ|mdr|lvz|Zeit\\s?Online|Thüringen24|wdr|thueringen24|jenatv|Thüringer\\sAllgemeine|	
Ostthüringer\\sZeitung|nnz|faz|DIE\\sWELT|Thüringen\\s24|Thüringische\\sLandeszeitung|inSüdthüringen|Deutschlandfunk|ntv|Süddeutsche\\sZeitung|Stern|spiegel", source, ignore.case = TRUE) ~ "Presse",
                                  grepl("facebook|twitter|Social Media|soziale Medien|youtube", source, ignore.case = TRUE) ~ "Soziale Medien",
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

# be really explicit: app expects, city, description, date, title, longitude, latitude, source_group, source_name, county
chronik_enriched <- chronik_enriched %>%
  rename(city = place, description = paragraph, latitude = lat, longitude = lon, county = admin6, source_name = source, date = datum) %>% 
  filter(!is.na(date))

