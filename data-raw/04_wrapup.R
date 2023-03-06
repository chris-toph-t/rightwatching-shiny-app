map_chronik <- chronik_clean %>% dplyr::group_by(placestring) %>% 
  dplyr::summarise(n = n()) %>% 
  ungroup %>% 
  add_column(lat = as.numeric(NA)) %>% 
  add_column(lon = as.numeric(NA)) %>% 
  add_column(admin6 = as.character(NA))

#do the actual geocoding
for (i in 1:length(map_chronik$placestring)) {
  result <- geocode(map_chronik$placestring[i])
  map_chronik$lat[i] <- result$lat
  map_chronik$lon[i] <- result$lon
  map_chronik$admin6[i] <- as.character(result$admin6)
  message(i)
}


#bring lon, lat, admin6 back into original data. not very elegant
chronik_clean %>%
  left_join(select(map_chronik, -n), by = c(placestring = "placestring")) -> chronik_enriched

# be really explicit: app expects, city, description, date, title, longitude, latitude, source_group, source_name, county
chronik_enriched <- chronik_enriched %>%
  rename(city = place, description = description, latitude = lat, longitude = lon, county = admin6, source_name = source_name, date = date) %>% 
  filter(!is.na(date))

chronik_sf <- chronik_enriched %>% 
  filter(!is.na(longitude)) %>% 
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)
