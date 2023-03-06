
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

