tabPanel(title = "Daten im Kontext",
         id    = "contextualizeTab",
         value = "contextualizeTab",
         icon  = icon("globe"),
         
         
         # context_map start ############################################################'
         fluidRow(column(3,
                         # links: -----------------------------------------------------------------------
                         textAreaInput("context_map_header1", "Überschrift", value = "Vorfälle im Kontext", rows = 2, resize = "none") %>%
                                 shiny::tagAppendAttributes(style = 'width: 100%;'),
                         selectInput("context_map_option1", "Rechte Gewalt vergleichen mit...",
                                     c("Wahlergebnisse" = "Wahlergebnisse",
                                       "Bevölkerung" = "Bevölkerung", 
                                       "AusländerInnen-Anteil" = "AusländerInnen-Anteil", 
                                       "NSDAP-WählerInnen 1933" = "NSDAP-WählerInnen 1933")),
                         uiOutput("context_map_option2"),
                         textAreaInput("context_map_text1", "Beschreibung", value = "Vorfälle rechter Gewalt zusammen mit Wahlergebnissen, Bevölkerungsdichte, etc", rows = 7, resize = "none") %>%
                                 shiny::tagAppendAttributes(style = 'width: 100%;')
                         
                         # ------------------------------------------------------------------------------
         ), column(width = 9,
                   # rechts:-----------------------------------------------------------------------
                   h3(textOutput("context_map_header1")),
                   plotOutput('context_map', height = "600px"),
                   p(textOutput("context_map_text1"))
                   # ------------------------------------------------------------------------------
         )),
         # context_map end ###############################################################
         
)