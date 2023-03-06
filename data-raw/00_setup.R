#cairo chunk setting needed for pdf rendering
knitr::opts_chunk$set(dev=c('png'),  comment="")
knitr::opts_chunk$set(dev.args=list(bg="transparent"))
library(librarian)
shelf(CorrelAid/datenguideR, hrbrthemes, viridis, readxl, jsonlite, tidyverse, lubridate, osmdata, 
      ggspatial, sp, htmltools, rvest, xml2, quanteda, ggrepel, sf, wordcloud, httr, giscoR, tidyr, 
      tryCatchLog, futile.logger, haven, knitr, blastula, parallelly, future,
      lib = lib_paths()[1])

library(future)
plan(multisession, workers = parallelly::availableCores())

Sys.setlocale("LC_TIME","de_DE.UTF-8")

#flog.appender(appender.file("prepare.log"))

theme_transparent <- function(base_size = 12, base_family = "Helvetica"){
  theme_void() %+replace%
    theme(
      panel.background = element_rect(fill = "transparent", color = NA), # bg of the panel
      plot.background = element_rect(fill = "transparent", color = NA),
      legend.position = "bottom"
    )
}

sendstatus <- function() {
  
  status_map <- ggplot() + 
    geom_sf(data = kreise, aes(geometry = geometry), fill = "white") +
    geom_sf(data = st_jitter(chronik_sf), size = 0.5) +
    coord_sf() + 
    #theme(legend.position = "none") +
    #labs(size = label) + 
    ggthemes::theme_map() +
    theme(legend.position = "right") +
    labs(title = "Incidents I scraped just now")
  
  gg_image <- add_ggplot(plot_object = status_map)
  
  email <- 
    compose_email(
      body = md(
        c("##", bundesland, " Scraper finished<br>",
          "Incidents obtained: ", nrow(chronik_enriched), "<br>", 
          "Latest incident from: ", format.Date(max(chronik_enriched$date), "%a %b %d %Y"), "<br>", 
          "Incidents not located: ", nrow(filter(chronik_enriched, is.na(latitude))), "<br>", 
          kable(table(filter(chronik_enriched, is.na(latitude))$placestring), format = "html"), "<br>", 
          gg_image
        )
      )
    )
  smtp_send(
    email = email,
    from = "support@rightwatching.org",
    to = "chris@toph.eu",
    credentials = creds_file("blastula.json")
  )
}  