
#basic cleaning, taking remove entries without place and create string for geocoding
chronik %>%
  mutate(placestring = str_replace_all(place, "\\s", "+")) %>%
  mutate(placestring = paste0(placestring, "+Thüringen")) -> chronik_clean

#need improvement: what do when multiple sources? take only first mentioned source?
chronik_clean %>%
  mutate(source_name = str_remove(source_name, "Quelle:\\s*")) %>%
  mutate(source_group = case_when(grepl("augenzeug", source_name, ignore.case = T) ~ "Augenzeugen",
                                  grepl("mobit", source_name, ignore.case = TRUE) ~ "MOBIT",
                                  grepl("ezra", source_name, ignore.case = TRUE) ~ "EZRA",
                                  grepl("polizei|lfv|verfassungsschutz", source_name, ignore.case = TRUE) ~ "Polizei/LfV",
                                  grepl("TA|TLZ|OTZ|mdr|lvz|Zeit\\s?Online|Thüringen24|wdr|thueringen24|jenatv|Thüringer\\sAllgemeine|	
Ostthüringer\\sZeitung|nnz|faz|DIE\\sWELT|Thüringen\\s24|Thüringische\\sLandeszeitung|inSüdthüringen|Deutschlandfunk|ntv|Süddeutsche\\sZeitung|Stern|spiegel", source_name, ignore.case = TRUE) ~ "Presse",
                                  grepl("facebook|twitter|Social Media|soziale Medien|youtube", source_name, ignore.case = TRUE) ~ "Soziale Medien",
                                  TRUE ~ "Andere"
  )) -> chronik_clean




