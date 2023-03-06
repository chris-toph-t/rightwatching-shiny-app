
#basic cleaning, taking remove entries without place and create string for geocoding
chronik %>%
  filter(!is.na(place)) %>%
  select(-descr) %>%
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
