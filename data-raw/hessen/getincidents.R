site = GET("https://hessenschauthin.de/wp-json/wp/v2/posts?categories=48")
x = headers(site)$`x-wp-total`
maxPages = ceiling(as.numeric(x)/100)

chronik <- data.frame()
for (i in 1:maxPages) {
  posts <- read_json(paste0("https://hessenschauthin.de/wp-json/wp/v2/posts?per_page=100&categories=48&page=", i), simplifyVector = TRUE)
  
  chronik_clean <- data.frame(date = posts$date, 
                              title = posts$title$rendered,
                              descr = posts$content$rendered,
                              link = posts$link
  )
  rbind(chronik_clean, chronik) -> chronik
}
#extract text from html code out of each description with lapply, same for href (links) and linked word (a)
chronik %>%
  mutate(descr_text = lapply(.$descr, function(x) {
    webpage <- read_html(x)
    trimws(html_text(webpage))
  })) %>%
  mutate(source_links = lapply(.$descr, function(x) {
    webpage <- read_html(x)
    html_nodes(webpage, "a") %>%
      html_attr("href") 
  })) %>%
  mutate(source_name = lapply(.$descr, function(x) {
    webpage <- read_html(x)
    html_nodes(webpage, "a") %>%
      html_text() 
  })) %>%
  # unnest(cols = c(descr_text)) %>%
  # unnest(cols = c(sources)) %>%
  # unnest(cols = c(source_links)) %>%
  #place is always at beginning of string and followed by : . So extract place with regexp
  mutate(place = str_remove(str_extract(descr_text, "^.*?:"), ":")) %>%
  mutate(date = as.Date(lubridate::ymd_hms(date))) %>%
  mutate(month = as.Date(cut.Date(date, breaks = "month"))) %>%
  mutate(year = as.Date(cut.Date(date, breaks = "year"))) %>%
  mutate(week = as.Date(cut.Date(date, breaks = "week"))) -> chronik





