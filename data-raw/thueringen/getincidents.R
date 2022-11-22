# not updated regularly?
ezra_raw <- read_json("https://angstraeume.ezra.de/wp-json/ezra/v1/chronic", simplifyVector=TRUE)
ezradata <- ezra_raw$entries

chronik <- ezradata %>% 
  rename(title = title, date = startDisplay, descr_text = content, place = locationDisplay, source_links = sourceUrl) %>% 
  select(title, date, descr_text, place, source_links)
