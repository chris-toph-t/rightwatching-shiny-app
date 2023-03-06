
#basic cleaning, taking remove entries without place and create string for geocoding
chronik %>%
  mutate(placestring = str_replace_all(place, "\\s", "+")) %>%
  mutate(placestring = paste0(placestring, "+Thüringen")) -> chronik_clean

#need improvement: what do when multiple sources? take only first mentioned source?
chronik_clean %>%
  mutate(source_name = str_remove(source_name, "Quelle:\\s{0,2}")) %>%
  mutate(source_group = case_when(grepl("antifa|antira", source_name, ignore.case = T) ~ "SzenebeobachterInnen",
                                  grepl("Kontaktaufnahm", source_name, ignore.case = T) ~ "Betroffene",
                                  grepl("mobit|kooperationspartn", source_name, ignore.case = T) ~ "Beratungsstellen",
                                  grepl("polizei|blaulicht|LPI", source_name, ignore.case = TRUE) ~ "Polizei",
                                  grepl("twitter|facebook|youtube", source_name, ignore.case = TRUE) ~ "Soziale Medien",
                                  grepl("Allgemeine|Freies\\sWort|Thühringer|Nachrichten|Welt|OTZ|Thüringer\\sAllgemein|Thüringen24|Ostthüringer\\sZeitung|Zeitung|Landeszeitung|MDR|TLZ|Jenapolis|Neues\\sDeutschland|TA|Spiegel|taz|Zeit", source_name, ignore.case = TRUE) ~ "Presse",
                                  TRUE ~ "Andere"
  )) -> chronik_clean

