################################StartGet Geo Reference###############################
    #get NUTS-LAU correspondance via communes
    communes <- read_sf("../data/COMM_RG_01M_2016_4326.geojson") %>%
      filter(str_detect(CNTR_CODE, "DE")) %>%
      mutate(AGS_KREIS_ID = str_extract(NSI_CODE, "^.{5}")) %>%
      filter(str_detect(NSI_CODE, paste0("^", bundesland)))
    
    # keep correspondence matches in simple table
    communes %>%
      sf::st_drop_geometry() %>%
      dplyr::select(NUTS_CODE, AGS_KREIS_ID) %>%
      dplyr::distinct() -> nuts_lau_match
    # add AGS/NSI code to kreise and keep only relevant state
    kreise <- gisco_get_nuts(nuts_level = "3", country = "DEU", resolution = "03", cache = TRUE) %>%
      left_join(nuts_lau_match, by = c(NUTS_ID = "NUTS_CODE")) %>%
      filter(str_detect(AGS_KREIS_ID, paste0("^", bundesland))) %>%
      sf::st_as_sf()
    bundesland_sf <- kreise %>% 
      summarise()
    #sf::write_sf(kreise, paste0("../data/kreise_", bundesland, ".shp"))
    #Encoding(kreise$NAME_LATN) <- "UTF-8"
################################End Get Geo Reference###############################

    
################################Start Get Poplation Data###############################
# Download Population data and grid if needed, keep only kreise of current bundesland, normalize pop values with cap of 5000, remove unneeded arge variables
    # Download Bevölkerungsraster 1km
    # https://ec.europa.eu/eurostat/de/web/gisco/geodata/reference-data/population-distribution-demography/geostat#geostat11
    if (file.exists("../data/georeference/population_deu_2019-07-01_geotiff/population_deu_2019-07-01.tif") == FALSE) {
      curl::curl_download(url = "https://data.humdata.org/dataset/7d08e2b0-b43b-43fd-a6a6-a308f222cdb2/resource/7c02d6ee-1630-42bb-abcd-90bc7b3fa169/download/population_deu_2019-07-01_geotiff.zip", destfile = "pop.zip")  
      unzip("pop.zip")
      dir.create("../data/georeference/")
      file.copy(from = "population_deu_2019-07-01.tif", to = "../data/georeference/")
      file.copy(from = "population_deu_2019-07-01.tif.aux.xml", to = "../data/georeference/", recursive = TRUE)
      #unlink("Version 2_0_1", recursive = TRUE)
      unlink("pop.zip")
    }
   
    # Process population data
    # pop_meta <- raster("../data/georeference/population_deu_2019-07-01_geotiff/population_deu_2019-07-01.tif")
    # 
    # pop_meta_filtered <- raster::crop(pop_meta, bundesland_sf)
    pop_meta = read_stars("../data/georeference/population_deu_2019-07-01_geotiff/population_deu_2019-07-01.tif")
    pop_meta_cropped <- pop_meta[bundesland_sf]
    names(pop_meta_cropped) <- "pop_density"
    #pop_meta_cropped <- stars::st_downsample(pop_meta_cropped, n = 10)
    rm(pop_meta)
################################End Get Poplation Data###############################

    
    
#################################Start nationality stats data from regionalstatistik##########################
    nationality_data <- dg_call(nuts_nr = "3", stat_name = "BEVSTD", substat_name = "NAT",parameter = c("NATA", "NATD"), year = "2019", parent_chr = bundesland)
    
    nationality_data_percentage <- nationality_data %>%
      tidyr::pivot_wider(id_cols = c(id, name), names_from = NAT, values_from = value) %>%
      mutate(NATA_percentage = (NATA/NATD)*100)
    
    #get election stats data, calculate percentage of AfD votes, parameter = c("AFD")
    votes_data <- dg_call(nuts_nr = "3", stat_name = "WAHL09", substat_name = "PART04", year = "2017", parent_chr = bundesland)
    voters_data <- dg_call(nuts_nr = "3", stat_name = "WAHL01", year = "2017", parent_chr = bundesland)
    votes_data <- votes_data %>%
      left_join(dplyr::select(voters_data, voters = value, id), by = c("id" = "id")) %>%
      mutate(vote_percentage = (value/voters)*100)
    # add statistics to kreis shapes
    kreise %>%
      #left_join(select(votes_data, id, vote_percentage), by = c("AGS_KREIS_ID" = "id")) %>%
      left_join(dplyr::select(nationality_data_percentage, id, NATA_percentage), by = c("AGS_KREIS_ID" = "id")) -> kreise
    
#################################End nationality stats data from regionalstatistik##########################

#############################Get NSDAP Votes####################
    if (file.exists("../data/historic_cleaned.rds") == FALSE) {
      #get dta file: https://search.gesis.org/research_data/ZA8013
      historic_elections <- haven::read_dta("../data/ZA8013_Wahldaten.dta")
      
      historic_elections %>%
        mutate(place = str_replace(name, "\\sS$", " city")) %>% 
        mutate(place = str_remove(place, "\\sL$")) %>%
        mutate(place = str_remove(place, "REST-")) %>%
        mutate(nsdap_percent_33 = (n333nsda/n333as)*100) %>%
        mutate(nsdap_percent_32n = (n32nnsda/n32nas)*100) %>%
        mutate(nsdap_percent_327 = (n327nsda/n327as)*100) %>%
        mutate(nsdap_percent_30 = (n309nsda/n309as)*100) -> historic_cleaned
      
      for (i in 1:length(historic_cleaned$place)) {
        result <- geocode(historic_cleaned$place[i])
        historic_cleaned$lat[i] <- result$lat
        historic_cleaned$lon[i] <- result$lon
        historic_cleaned$admin6[i] <- as.character(result$admin6)
        message(i)
      }
      saveRDS(historic_cleaned, file = "../data/historic_cleaned.rds")
      }
    
    historic_cleaned <- read_rds("../data/historic_cleaned.rds")
    historic_cleaned %>%
      filter(lon > sf::st_bbox(kreise)$xmin) %>%
      filter(lon < sf::st_bbox(kreise)$xmax) %>%
      filter(lat > sf::st_bbox(kreise)$ymin) %>%
      filter(lat < sf::st_bbox(kreise)$ymax) -> historic_filtered
    
    rm(historic_elections)
    rm(historic_cleaned)
    
    
#############################End Get NSDAP Votes####################