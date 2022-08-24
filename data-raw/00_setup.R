#cairo chunk setting needed for pdf rendering
knitr::opts_chunk$set(dev=c('png'),  comment="")
knitr::opts_chunk$set(dev.args=list(bg="transparent"))
library(librarian)
shelf(CorrelAid/datenguideR, hrbrthemes, viridis, readxl, jsonlite, tidyverse, lubridate, osmdata, 
      ggspatial, sp, htmltools, rvest, xml2, quanteda, ggrepel, sf, wordcloud, httr, giscoR, tidyr, 
      tryCatchLog, futile.logger, haven, knitr, blastula, raster, stars, lib = lib_paths()[1])

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
  email <- 
    compose_email(
      body = md(
        c("##", bundesland, " Scraper finished<br>",
          "Incidents obtained: ", nrow(chronik_enriched), "<br>", 
          "Latest incident from: ", format.Date(max(chronik_enriched$date), "%a %b %d"), "<br>", 
          "Incidents not located: ", nrow(filter(chronik_enriched, is.na(admin6))), "<br>", 
          kable(table(filter(chronik_enriched, is.na(lat))$placestring), format = "html"), "<br>", 
          "Other things I obtained: ", ls()
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