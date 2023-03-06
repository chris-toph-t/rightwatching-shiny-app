

maxPages <- read_html("https://www.leuchtlinie.de/chronik") %>%
  html_nodes(".pager-last > a:nth-child(1)") %>%
  html_attr("href") %>%
  str_extract("\\d{3}$") %>% 
  as.numeric()

chronik <- data.frame(iteration=integer(),title=character(), date=character(), descr_text=character(), place=character(), source_links=character(),  stringsAsFactors=FALSE)

page_scrape <- function(i) {
  doc <- read_html(paste0("https://www.leuchtlinie.de/chronik?page=", i))
  #keep track of iterations 
  iteration <- i
  names(iteration) <- "iteration"
  #define parent node
  payload <- html_nodes(doc, css = ".view-content")

  #extract date with if statement to fill empty nodes with NA
  date <- payload %>%
    html_nodes(.,css = ".date-display-single") %>%
    html_text() %>%
    trimws()
  names(date) <- "date"
  
  title <- payload %>%
    html_nodes(.,css = ".views-field-title") %>%
    html_text() %>%
    trimws()
  names(title) <- "title"
  
  descr_text <- payload %>%
    html_nodes(.,css = ".views-field-body") %>%
    html_text() %>%
    trimws()
  names(descr_text) <- "descr_text"
  
  place <- payload %>%
    html_nodes(.,css = ".views-field-field-chronik-stadt") %>%
    html_text() %>%
    trimws()
  names(place) <- "place"

  
  source_links <- payload %>%
    html_nodes(.,css = ".views-field-field-chronik-quelle") %>%
    html_text() %>%
    trimws()
  names(source_links) <- "source_links"
  
  
  temp <- tibble(title, date, descr_text, place, source_links)
  chronik <<- rbind(chronik, temp)
}
print(paste0("Max pages: ", maxPages))
# here scraping starts, be nice and keep the sleep time between 1 and 2 seconds
for (i in 1:maxPages) {
  page_scrape(i)
  message(i)
  Sys.sleep(runif(1, min = 1, max = 2))
}


chronik <- chronik %>%
  mutate(date = as.Date(lubridate::dmy(date))) %>%
  mutate(month = as.Date(cut.Date(date, breaks = "month"))) %>%
  mutate(year = as.Date(cut.Date(date, breaks = "year"))) %>%
  mutate(week = as.Date(cut.Date(date, breaks = "week"))) %>% 
  mutate(source_name = as.character(NA))






