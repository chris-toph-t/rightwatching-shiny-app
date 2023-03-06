# on json api at https://angstraeume.ezra.de/wp-json/ezra/v1/chronic
# events are pushed with delay
# using chornic from website instead.

#using maunally browser downloaded file for now. 
# replace with RSelenium later
doc <- read_html(file.path("thueringen", "index.html"))
#doc <- read_html("https://ezra.de/chronik/")


ezradata <- data.frame(iteration=integer(),title=character(), datum=character(), paragraph=character(), place=character(), quelle=character(), link=character(), stringsAsFactors=FALSE)

#define f to scrape each event from html and stick into df
page_scrape <- function(i) {
  #define parent node
  payload <- html_elements(doc, paste("article.chronic__entry:nth-child(",i,")", sep=""))
  #keep track of iterations 
  iteration <- i
  names(iteration) <- "iteration"
  #extract date with if statement to fill empty nodes with NA
  datum <- payload %>%
    {ifelse(
      is.null(html_text(html_element(.,".chronic__entry__date--start"))), 
      NA,html_text(html_nodes(.,".chronic__entry__date--start")))}
  names(datum) <- "datum"
  
  title <- payload %>% 
    {ifelse(
      is.null(html_text(html_element(.,".chronic__entry__heading__title"))), 
      NA,html_text(html_element(.,".chronic__entry__heading__title")))}
  names(title) <- "title"
  
  paragraph <- payload %>% 
    {ifelse(
      is.null(html_text(html_element(.,".chronic__entry__content-wrapper p"))), 
      NA,html_text(html_element(.,".chronic__entry__content-wrapper p")))}
  names(paragraph) <- "paragraph"
  
  place <- payload %>% 
    {ifelse(
      is.null(html_text(html_element(.,".chronic__entry__heading__location"))), 
      NA,html_text(html_element(.,".chronic__entry__heading__location")))}
  names(place) <- "place"
  
  
  quelle <- payload %>% 
    {ifelse(
      is.null(html_text(html_element(.,".chronic__entry__source"))), 
      NA,html_text(html_element(.,".chronic__entry__source")))}
  names(quelle) <- "quelle"
  
  link <- payload %>% 
    {ifelse(
      is.null(html_attr(html_element(.,".chronic__entry__source a"), "href")), 
      NA,html_attr(html_element(.,".chronic__entry__source a"), "href"))}
  names(link) <- "link"
  
  temp <- tibble(iteration,title, datum, paragraph, place, quelle, link)
  ezradata <<- rbind(ezradata, temp)
  
}


incident_nb <- length(html_nodes(doc, ".chronic__entry"))
for (i in 1:incident_nb){
  page_scrape(i)
  message(i)
}

# legacy part from json API
# ezra_raw <- read_json("https://angstraeume.ezra.de/wp-json/ezra/v1/chronic", simplifyVector=TRUE)
# ezradata <- ezra_raw$entries

chronik <- ezradata %>% 
  rename(title = title, date = datum, descr_text = paragraph, place = place, 
         source_links = link, source_name = quelle) %>% 
  mutate(date = lubridate::dmy(date))



