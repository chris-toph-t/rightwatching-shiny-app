#define geocoding function
geocode <- function(place = NULL){
  # NOMINATIM SEARCH API URL
  # use this one if you don't have your own docker nominatim instance
  #src_url <- "https://nominatim.openstreetmap.org/search?q="
  src_url <<- "http://nominatim.geocode:8080/search?q="
  # if more than one field per address, concatenate here
  addr <- place
  # Such-URL erstellen
  request <- paste0(src_url, addr, "&format=geocodejson&accept-language=de&addressdetails=[1]")
  # durch die Orte gehen und Anfrage stellen
  if(suppressWarnings(is.null(addr)))
    return(data.frame())
  # transformNomiatim response to json
  response <- 
    tryCatch(
      jsonlite::fromJSON(html_text(html_node(read_html(request), "p"))), 
    error = function(c) return(data.frame())
    )
  # Get lon, Lat, Admin6, admin4 from response
  if (length(response$features$geometry$coordinates[[1]][1]) == 0) {
    lon <- NA
  }
  else {
    lon <- response$features$geometry$coordinates[[1]][1]  
  }
  if (length(response$features$geometry$coordinates[[1]][2]) == 0) {
    lat <- NA
  }
  else {
    lat <- response$features$geometry$coordinates[[1]][2]  
  }
  if (length(response$features$properties$geocoding$admin$level6[[1]]) == 0) {
    admin6 <- NA
  }
  else {
    admin6 <- response$features$properties$geocoding$admin$level6[[1]]  
  }
  if (length(response$features$properties$geocoding$admin$level4[[1]]) == 0) {
    admin4 <- NA
  }
  else {
    admin4 <- response$features$properties$geocoding$admin$level4[[1]]  
  }
  return(data.frame(lat,lon,admin6, admin4))
}
