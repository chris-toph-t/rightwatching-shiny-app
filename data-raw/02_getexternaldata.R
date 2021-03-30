################################StartGet Geo Reference###############################
    #get NUTS-LAU correspondance via communes
    communes <- read_sf("../data/COMM_RG_01M_2016_4326.geojson") %>%
      filter(str_detect(CNTR_CODE, "DE")) %>%
      mutate(AGS_KREIS_ID = str_extract(NSI_CODE, "^.{5}")) %>%
      filter(str_detect(NSI_CODE, paste0("^", bundesland)))
    
    # keep correspondence matches in simple table
    communes %>%
      sf::st_drop_geometry() %>%
      select(NUTS_CODE, AGS_KREIS_ID) %>%
      dplyr::distinct() -> nuts_lau_match
    # add AGS/NSI code to kreise and keep only relevant state
    kreise <- gisco_get_nuts(nuts_level = "3", country = "DEU", resolution = "03", cache = TRUE, update_cache = TRUE) %>%
      left_join(nuts_lau_match, by = c(NUTS_ID = "NUTS_CODE")) %>%
      filter(str_detect(AGS_KREIS_ID, paste0("^", bundesland))) %>%
      sf::st_as_sf()
    #sf::write_sf(kreise, paste0("../data/kreise_", bundesland, ".shp"))
    #Encoding(kreise$NAME_LATN) <- "UTF-8"
################################End Get Geo Reference###############################

    
################################Start Get Poplation Data###############################
# Download Population data and grid if needed, keep only kreise of current bundesland, normalize pop values with cap of 5000, remove unneeded arge variables
    # Download Bevölkerungsraster 1km
    # https://ec.europa.eu/eurostat/de/web/gisco/geodata/reference-data/population-distribution-demography/geostat#geostat11
    if (file.exists("../data/georeference/GEOSTAT_grid_POP_1K_2011_V2_0_1.csv") == FALSE) {
      curl::curl_download(url = "https://ec.europa.eu/eurostat/cache/GISCO/geodatafiles/GEOSTAT-grid-POP-1K-2011-V2-0-1.zip", destfile = "pop.zip")  
      unzip("pop.zip")
      dir.create("../data/georeference/")
      file.copy(from = "Version 2_0_1/GEOSTAT_grid_POP_1K_2011_V2_0_1.csv", to = "../data/georeference/")
      file.copy(from = "Version 2_0_1/GEOSTATReferenceGrid", to = "../data/georeference/", recursive = TRUE)
      unlink("Version 2_0_1", recursive = TRUE)
      unlink("pop.zip")
    }
    
    # Process population data
    
    read.csv("../data/georeference/GEOSTAT_grid_POP_1K_2011_V2_0_1.csv") -> pop2011
    read_sf("../data/georeference/GEOSTATReferenceGrid/Grid_ETRS89_LAEA_1K-ref_GEOSTAT_POP_2011_V2_0_1.shp") -> pop2011_ref
    
    pop2011_ref %>%
      left_join(pop2011, by = c(GRD_ID = "GRD_ID")) %>%
      filter(CNTR_CODE == "DE") -> pop2011
    #keep population grid only for relevant bundesland
    st_transform(pop2011, crs = (st_crs(kreise))) -> pop2011
    st_intersection(kreise, pop2011) -> pop2011_filtered
    
    #set cut off value for 5000 to properly show sparsely populated places
    pop2011_filtered %>%
      mutate(TOT_P = as.numeric(TOT_P)) %>%
      mutate(TOT_P = if_else(TOT_P > 5000, 5000, TOT_P)) -> pop2011_filtered
    
    #sf::write_sf(pop2011_filtered, paste0("../data/pop2011_", bundesland,".shp"), "pop2011")
    
    rm(pop2011)
    rm(pop2011_ref)
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
      left_join(select(voters_data, voters = value, id), by = c("id" = "id")) %>%
      mutate(vote_percentage = (value/voters)*100)
    # add statistics to kreis shapes
    kreise %>%
      #left_join(select(votes_data, id, vote_percentage), by = c("AGS_KREIS_ID" = "id")) %>%
      left_join(select(nationality_data_percentage, id, NATA_percentage), by = c("AGS_KREIS_ID" = "id")) -> kreise
    
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