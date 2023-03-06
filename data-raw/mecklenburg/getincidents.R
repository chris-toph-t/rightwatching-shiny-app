
chronik <- data.frame(date=character(), descr_text=character(), place=character(), county=character(), sources=character(),  stringsAsFactors=FALSE)

page_scrape <- function() {
  
  doc <- read_html("https://lobbi-mv.de/such-ergebnisse-chronologie/?ort=&landkreis=&delikt=&motiv=&von=&bis=") %>%
    html_nodes("#main")
  #define parent node
  payload <- doc %>%
    html_nodes(".category-chronologie")
  
  
  #extract date with if statement to fill empty nodes with NA
  date <- payload %>%
    html_nodes(.,"h3") %>%
    html_text() %>%
    str_extract(".*?\\s-") %>%
    str_remove("\\s-") %>%
    trimws()
  names(date) <- "date"
  
  descr_text <- payload %>%
    html_nodes(.,css = ".intro-content") %>%
    html_text() %>%
    trimws()
  names(descr_text) <- "descr_text"
  
  place <- payload %>%
    html_nodes(.,"h3") %>%
    html_text() %>%
    str_extract("-\\s.*?\\s\\(") %>%
    str_remove_all("-\\s|\\s\\(") %>%
    trimws()
  names(place) <- "place"
  
  county <- payload %>%
    html_nodes(.,css = ".title-zusatz-landkreis") %>%
    html_text() %>% 
    str_remove_all("\\(|\\)") %>%
    trimws()
  names(county) <- "county"
  
  
  sources <- payload %>%
    html_nodes(.,css = ".quelle") %>%
    html_text() %>%
    trimws()
  names(sources) <- "sources"
  
  
  temp <- tibble(date, descr_text, place, county, sources)
  chronik <<- rbind(chronik, temp)
}

# here scraping starts, be nice and keep the sleep time between 1 and 2 seconds
page_scrape()


chronik %>%
  mutate(date = as.Date(lubridate::dmy(date))) %>%
  mutate(month = as.Date(cut.Date(date, breaks = "month"))) %>%
  mutate(year = as.Date(cut.Date(date, breaks = "year"))) %>%
  mutate(week = as.Date(cut.Date(date, breaks = "week"))) %>% 
  rename(source_name = sources) -> chronik





