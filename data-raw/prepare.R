# this is the lAunch script to scrape all data, process it and store it in Rdata files. 
# in this folder reside common scripts that are the same for all chronciles
# each folder has scripts specific to the chronicle


setwd("/srv/prepare/")
# when not using docker use the following line for working direcotry
#setwd("data-raw/")



source("00_setup.R")
chronicles <- read_csv(file.path("data-raw", "conversion_table_tatortrechts.csv"))


for (i in 1:2) {
  incidents <- readr::read_csv(file.path("..", "data", "tatortrechts.csv"))
  sources <- readr::read_csv(file.path("..", "data", "sources.csv"))
  incidents <- incidents %>%
    left_join(select(sources, source_name = name, source_url = url, source_date = date, id), by = c("id" = "id"))
  
  incidents %>%
    #mutate(source_links = str_remove(source_links, "Quelle:\\s{5}")) %>%
    mutate(source_name_cleaned = tm::removePunctuation(str_remove(str_extract(source_name, "//.*?(/|$)"), "(//www.|//)"))) %>%
    mutate(source_group = case_when(grepl("netzgegennazis|antifa|belltowernews|endstationrechts|npdblog", source_name, ignore.case = T) ~ "rechtsaussen", 
                                    grepl("presseportal|blaulichtatlas|polizei|bka|lka", source_name, ignore.case = TRUE) ~ "Polizei",
                                    grepl("kleineanfrage|bundestag|parlament|anfrage|drucksache|landtag", source_name, ignore.case = TRUE) ~ "Parlamentarische Anfragen",
                                    grepl("augenzeug|zeuginnenberichte|zeugen|zeuginnen", source_name, ignore.case = TRUE) ~ "AugenzeugInnen",
                                    grepl("betroffene", source_name, ignore.case = TRUE) ~ "Betroffene",
                                    grepl("opp|opferperspektive|leuchtlinie|ezra|RAA|lobbi|reachout|keine randnotiz|opferberatung|m/*power|mobit|amadeu|response", source_name, ignore.case = TRUE) ~ "Org",
                                    grepl("thüringen24|wdr|rbb24|rbbonline|berlinonline|rbb|express|ndr|dpa|otz|tlz|bild|moz|maz|jenapolis|rponline|
                                        lokalredaktion|tageblatt|pnr|rias|faz|tag24|welt|szonline|
                                        rbb|lvz|rundschau|taz|zeitung|allgemeine|anzeiger|news|
                                        bote|post|chronik|spiegel", source_name, ignore.case = TRUE) ~ "Zeitungen",
                                    TRUE ~ "Andere"
    )) -> chronik_clean
  
  bundesland <- chronicles$ags[i]
  chronik_enriched <- chronik_clean %>%
    filter(chronicler_name == chronicles$chronicler_name[i])
  source("01_def_geocode.R", verbose = TRUE)  
  source("02_getexternaldata.R", verbose = TRUE)
  rm(chronik_clean)
  rm(incidents)
  save.image(file = paste0("../data/", tm::removePunctuation(chronicles$chronicler_name[i]), ".RData"))
  message(i)
}





library(tryCatchLog)
library(futile.logger)

######################### prepare sequence for hessen
                bundesland <- "06"
                source("00_setup.R")
                source("hessen/getincidents.R", verbose = TRUE)
                source("01_def_geocode.R", verbose = TRUE)
                source("02_getexternaldata.R", verbose = TRUE)
                print("Got all external data")
                #message(paste0("I'm about to send lots of requests to this server for geocoding: ", src_url))
                source("hessen/clean.R", verbose = TRUE)
                message(paste0("I have not found geolocation for ", nrow(filter(chronik_enriched, is.na(lat))), "incidents"))
                # to be added later
                #source("hessen/textmining.R", verbose = TRUE)
                #message("I just textmined the hell out of all this")
                save.image(file = "../data/hessenschauthin.RData")
                message("saved all Hessen data on host, ", nrow(chronik_enriched), " incidents")
                sendstatus()
                rm(list = ls())
 

########################## prepare sequence for baden wuerttemberg
                bundesland <- "08"
                source("00_setup.R")
                source("bawue/getincidents.R")
                source("01_def_geocode.R", verbose = TRUE)
                source("02_getexternaldata.R", verbose = TRUE)
                message("Got all external data")
                #message(paste0("I'm about to send lots of requests to this server for geocoding: ", src_url))
                source("bawue/clean.R")
                message(paste0("I have not found geolocation for ", nrow(filter(chronik_enriched, is.na(lat))), "incidents"))
                # to be added later
                #source("bawue/textmining.R")
                #message("I just textmined the hell out of all this")
                save.image(file = "../data/leuchtlinie.RData")
                message("saved all BaWue data on host, ", nrow(chronik_enriched), " incidents")
                sendstatus()
                rm(list = ls())
                
########################## prepare sequence for Mecklenburg Vorpommern
                bundesland <- "13"
                source("00_setup.R")
                source("mecklenburg/getincidents.R")
                source("01_def_geocode.R", verbose = TRUE)
                source("02_getexternaldata.R", verbose = TRUE)
                message("Got all external data")
                #message(paste0("I'm about to send lots of requests to this server for geocoding: ", src_url))
                source("mecklenburg/clean.R")
                message(paste0("I have not found geolocation for ", nrow(filter(chronik_enriched, is.na(lat))), "incidents"))
                # to be added later
                #source("mecklenburg/textmining.R")
                #message("I just textmined the hell out of all this")
                save.image(file = "../data/lobbi.RData")
                message("saved all Mecklenburg data on host, ", nrow(chronik_enriched), " incidents")
                sendstatus()
                rm(list = ls())
                
######################### prepare sequence for dummydata
                bundesland <- "10"
                source("00_setup.R")
                source("dummydata/getincidents.R", verbose = TRUE)
                source("01_def_geocode.R", verbose = TRUE)
                source("02_getexternaldata.R", verbose = TRUE)
                print("Got all external data")
                #message(paste0("I'm about to send lots of requests to this server for geocoding: ", src_url))
                source("dummydata/clean.R", verbose = TRUE)
                message(paste0("I have not found geolocation for ", nrow(filter(chronik_enriched, is.na(lat))), "incidents"))
                # to be added later
                #source("dummydata/textmining.R", verbose = TRUE)
                #message("I just textmined the hell out of all this")
                save.image(file = "../data/dummydata.RData")
                message("saved all Dummy data on host, ", nrow(chronik_enriched), " incidents")
                sendstatus()
                rm(list = ls())