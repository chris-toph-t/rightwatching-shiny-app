# prepare source column into corpus
corpus(chronik_enriched %>% unnest(descr_text) %>% .$descr_text) -> descr_corp
#add month as doc variable
# This would have to be adjusted to year for other orgs
docvars(descr_corp, field = "month") <- chronik_enriched$month
# make doc frequency matrix, where we remove german stopwords and punctuation, keeping only words occurring more than 5 times
descr_corp %>%
  dfm(remove = stopwords("german"), remove_punct = TRUE) %>%
  dfm_trim(min_termfreq = 5, verbose = FALSE) -> descr_dfm

# what words are in andere quellen category
# chronik_enriched %>%
#   filter(source_group == "Andere") %>%
#   unnest(sources) %>% 
#   group_by(sources) %>%
#   summarise(n = n()) -> quellentext