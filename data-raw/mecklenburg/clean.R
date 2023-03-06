
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
  )) %>% 
  dplyr::select(-county) -> chronik_clean
