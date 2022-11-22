#define geocoding function
geocode <- function(place = NULL){
  # NOMINATIM SEARCH API URL
  # use this one if you don't have your own docker nominatim instance
  #src_url <- "https://nominatim.openstreetmap.org/search?q="
  src_url <- "https://nominatim.datenlabor.eu/search?q="
  # if more than one field per address, concatenate here
  addr <- place
  # Such-URL erstellen
  request <- paste0(src_url, addr, "&format=json&accept-language=de&addressdetails=[1]")
  answer <- jsonlite::read_json(request, simplifyVector = TRUE)
  answer <- tryCatch(
    answer %>% 
      filter(importance == max(answer$importance)) %>% 
      unnest(cols = c(address)) %>% 
      mutate(lat = as.numeric(lat)) %>% 
      mutate(lon = as.numeric(lon)) %>% 
      select(lat, lon, admin4 = state, admin6 = county) %>% 
      slice(1), 
    error = function(c) return(tibble("lat" = as.numeric(NA), "lon" = as.numeric(NA), admin4 = as.character(NA), admin6 = as.character(NA)))
  )
  
  return(answer)
}
