# this is the lAunch script to scrape all data, process it and store it in Rdata files. 
# in this folder reside common scripts that are the same for all chronciles
# each folder has scripts specific to the chronicle


setwd("/srv/prepare/")
# when not using docker use the following line for working direcotry
#setwd("data-raw/")

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
                bundesland <- "09"
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