

#create empty df with columns to be scraped
mobitdata <- data.frame(iteration=integer(),title=character(), datum=character(), paragraph=character(), region=character(), place=character(), motivation=character(), quelle=character(), link=character(), stringsAsFactors=FALSE)
#read html, no need for session
doc <- read_html("https://mobit.org/chronik-extrem-rechter-aktivitaeten-in-thueringen/")

#define f to scrape each event from html and stick into df
page_scrape <- function(i) {
  #define parent node
  payload <- html_nodes(doc, paste("article.attack:nth-child(",i,")", sep=""))
  #keep track of iterations 
  iteration <- i
  names(iteration) <- "iteration"
  #extract date with if statement to fill empty nodes with NA
  datum <- payload %>%
    {ifelse(
      is.null(html_text(html_nodes(.,"date.date"))), 
      NA,html_text(html_nodes(.,"date.date")))}
  names(datum) <- "datum"
  
  title <- payload %>% 
    {ifelse(
      is.null(html_text(html_nodes(.,"h2 span.second_heading"))), 
      NA,html_text(html_nodes(.,"h2 span.second_heading")))}
  names(title) <- "title"
  
  motivation <- payload %>% 
    {ifelse(
      is.null(html_attr(.,"data-motivation")), 
      NA,html_attr(.,"data-motivation"))}
  names(motivation) <- "motivation"
  
  paragraph <- payload %>% 
    {ifelse(
      is.null(html_text(html_nodes(.,"div > p:nth-child(2)"))), 
      NA,html_text(html_nodes(.,"div > p:nth-child(2)")))}
  names(paragraph) <- "paragraph"
  
  place <- payload %>% 
    {ifelse(
      is.null(html_text(html_nodes(.,"div.attack_wrapper header h2 span.place"))), 
      NA,html_text(html_nodes(.,"div.attack_wrapper header h2 span.place")))}
  names(place) <- "place"
  
  region <- payload %>% 
    {ifelse(
      is.null(html_attr(.,"data-region")), 
      NA,html_attr(.,"data-region"))}
  names(region) <- "region"
  
  
  quelle <- payload %>% 
    {ifelse(
      is.null(html_text(html_nodes(.,"div.attack_wrapper p.source"))), 
      NA,html_text(html_nodes(.,"div.attack_wrapper p.source")))}
  names(quelle) <- "quelle"
  
  link <- payload %>% 
    {ifelse(
      is.null(html_attr(html_nodes(.,"div.attack_wrapper p.source a"), "href")), 
      NA,html_attr(html_nodes(.,"div.attack_wrapper p.source a"), "href"))}
  names(link) <- "link"
  
  temp <- tibble(iteration,title, datum, paragraph, region, place, motivation, quelle, link)
  mobitdata <<- rbind(mobitdata, temp)
  
  
}
#actual scraping magic happens here
incident_nb <- length(html_nodes(doc, "article"))
for (i in 1:incident_nb){
  page_scrape(i)
  message(i)
}


chronik <- mobitdata %>%
  mutate(datum = lubridate::dmy(datum)) %>%
  rename(source = quelle)


