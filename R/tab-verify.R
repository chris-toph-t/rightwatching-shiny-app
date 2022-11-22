tabPanel(title = "Daten prüfen",
         id    = "verifyTab",
         value = "verifyTab",
         icon  = icon("magnifying-glass"),
         
         # source_multiple start ############################################################'
         fluidRow(column(3,
                         # links: -----------------------------------------------------------------------
                         textAreaInput("source_multiple_header1", "Überschrift", value = "Wo welche Quellenarten berichten", rows = 2, resize = "none") %>%
                                 shiny::tagAppendAttributes(style = 'width: 100%;'),
                         textAreaInput("source_multiple_text1", "Beschreibung", value = "Welche Art von Quelle wo berichtet - oder genau nicht", rows = 7, resize = "none") %>%
                                 shiny::tagAppendAttributes(style = 'width: 100%;')
                         
                         # ------------------------------------------------------------------------------
         ), column(width = 9,
                   # rechts:-----------------------------------------------------------------------
                   h3(textOutput("source_multiple_header1")),
                   plotOutput('source_multiple_map', height = "600px"),
                   p(textOutput("source_multiple_text1"))
                   # ------------------------------------------------------------------------------
         )),
         # source_multiple end ###############################################################
         
         # source_mapcloud start ############################################################'
         fluidRow(
                column(3,
                         # links: -----------------------------------------------------------------------
                         textAreaInput("source_map_header1", "Überschrift", value = "Quellenart auswählen und mit allen anderen Vorfällen vergleichen", rows = 2, resize = "none") %>%
                                 shiny::tagAppendAttributes(style = 'width: 100%;'),
                         selectInput('source_map_option1', 'Quelle', choices = NULL, multiple = FALSE),
                         textAreaInput("source_map_text1", "Beschreibung", value = 'Vorfälle einer ausgewählten Quellengruppe (Schwarz) im Vergleich zu allen Vorfällen im anfangs gewählten Zeitraum. Rechts werden die Quellenlinks als Wortwolke dargestellt - vor allem hilfreich bei Quellengruppen "Andere" oder "Zeitungn"', rows = 7, resize = "none") %>%
                                 shiny::tagAppendAttributes(style = 'width: 100%;')
                         
                         # ------------------------------------------------------------------------------
         ), 
                column(width = 5,
                        # rechts:-----------------------------------------------------------------------
                        h3(textOutput("source_map_header1")),
                        plotOutput('source_map', height = "550px"),
                        p(textOutput("source_map_text1"))
                        # ------------------------------------------------------------------------------
         ), 
                column(width = 4,
                        # rechts:-----------------------------------------------------------------------
                        h3(textOutput("source_wordcloud_header1")),
                        plotOutput('source_wordcloud', height = "600px"),
                        p(textOutput("source_wordcloud_text1"))
                        # ------------------------------------------------------------------------------
         )),
         # source_mapcloud end ###############################################################
         # missing start ############################################################'
         fluidRow(column(3,
                         # links: -----------------------------------------------------------------------
                         textAreaInput("missing_table_header1", "Überschrift", value = "Vorfälle die nicht oder ungenau beschrieben sind", rows = 2, resize = "none") %>%
                           shiny::tagAppendAttributes(style = 'width: 100%;'),
                         textAreaInput("missing_table_text1", "Beschreibung", value = "Chroniken haben manchmal leere Felder. Hier werden Chronikeinträge mit leeren Beschreibungen dargestellt", rows = 7, resize = "none") %>%
                           shiny::tagAppendAttributes(style = 'width: 100%;')
                         
                         # ------------------------------------------------------------------------------
         ), column(width = 9,
                   # rechts:-----------------------------------------------------------------------
                   h3(textOutput("missing_table_header1")),
                   plotOutput('missing_plot'),
                   dataTableOutput('missing_table'),
                   p(textOutput("missing_table_text1"))
                   # ------------------------------------------------------------------------------
         )),
         # missing end ###############################################################
)