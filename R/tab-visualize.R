tabPanel(title = "Daten darstellen & beschreiben",
         id    = "visualizeTab",
         value = "visualizeTab",
         icon  = icon("bar-chart"),
         # barchart start ############################################################'
         fluidRow(column(3,
                         # links: -----------------------------------------------------------------------
                         textAreaInput("barchart_header1", "Überschrift", value = "Verlauf", rows = 2, resize = "none") %>%
                                 shiny::tagAppendAttributes(style = 'width: 100%;'),
                         selectInput("barchart_option1", "Zeitfenster",
                                     c("Woche" = "week",
                                       "Monat" = "month",
                                       "Jahr" = "year")),
                         textAreaInput("barchart_text1", "Beschreibung", value = "Daten Beschreibung", rows = 7, resize = "none") %>%
                                 shiny::tagAppendAttributes(style = 'width: 100%;')
                         
                         # ------------------------------------------------------------------------------
         ), column(width = 9,
                   # rechts:-----------------------------------------------------------------------
                   h3(textOutput("barchart_header1")),
                   plotOutput('barchart'),
                   p(textOutput("barchart_text1"))
                   # ------------------------------------------------------------------------------
         )),
         # barchart end ###############################################################
         
         
         
         # county_timeline start ############################################################'
         fluidRow(column(3,
                         # links: -----------------------------------------------------------------------
                         textAreaInput("county_timeline_header1", "Überschrift", value = "Entwicklung in Kreisen", rows = 2, resize = "none") %>%
                                 shiny::tagAppendAttributes(style = 'width: 100%;'),
                         selectInput('county_timeline_option1', 'Kreis', choices = NULL, multiple = TRUE),
                         textAreaInput("county_timeline_text1", "Beschreibung", value = "Daten Beschreibung", rows = 7, resize = "none") %>%
                                 shiny::tagAppendAttributes(style = 'width: 100%;')
                         
                         # ------------------------------------------------------------------------------
         ), column(width = 9,
                   # rechts:-----------------------------------------------------------------------
                   h3(textOutput("county_timeline_header1")),
                   plotOutput('county_timeline'),
                   p(textOutput("county_timeline_text1"))
                   # ------------------------------------------------------------------------------
         ))
         # county_timeline end ###############################################################
)
