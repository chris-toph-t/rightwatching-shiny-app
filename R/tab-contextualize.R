tabPanel(title = "Daten im Kontext",
         id    = "contextualizeTab",
         value = "contextualizeTab",
         icon  = icon("globe"),
         
         
         # election map start ############################################################'
         fluidRow(column(3,
                         # links: -----------------------------------------------------------------------
                         textAreaInput("context_map_header1", "Überschrift", value = "Vorfälle im Kontext von Bundestagswahlergebnissen", rows = 2, resize = "none") %>%
                                 shiny::tagAppendAttributes(style = 'width: 100%;'),
                         #uiOutput("context_map_option1"),
                         selectInput('context_map_option1', 'Partei auswählen', choices = NULL, multiple = FALSE),
                         textAreaInput("context_map_text1", "Beschreibung", value = "Vorfälle rechter Gewalt zusammen mit Wahlergebnissen laut regionalstatistik.de", rows = 7, resize = "none") %>%
                                 shiny::tagAppendAttributes(style = 'width: 100%;')
                         
                         # ------------------------------------------------------------------------------
         ), column(width = 9,
                   # rechts:-----------------------------------------------------------------------
                   h3(textOutput("context_map_header1")),
                   plotOutput('context_map1', height = "500"),
                   p(textOutput("context_map_text1"))
                   # ------------------------------------------------------------------------------
         )),
         # election map end ###############################################################
         # population map start ############################################################'
         fluidRow(column(3,
                         # links: -----------------------------------------------------------------------
                         textAreaInput("context_map_header2", "Überschrift", value = "Wo gibt es rechte Gewalt, wo wohnen Menschen", rows = 2, resize = "none") %>%
                           shiny::tagAppendAttributes(style = 'width: 100%;'),
                         textAreaInput("context_map_text2", "Beschreibung", value = "Vorfälle rechter Gewalt zusammen mit Bevölkerungsdichte, Quelle: eurostat gisco", rows = 7, resize = "none") %>%
                           shiny::tagAppendAttributes(style = 'width: 100%;')
                         
                         # ------------------------------------------------------------------------------
         ), column(width = 9,
                   # rechts:-----------------------------------------------------------------------
                   h3(textOutput("context_map_header2")),
                   plotOutput('context_map2', height = "600"),
                   p(textOutput("context_map_text2"))
                   # ------------------------------------------------------------------------------
         )),
         # population map end ############################################################
         # foreigner map start ############################################################
         fluidRow(column(3,
                         # links: -----------------------------------------------------------------------
                         textAreaInput("context_map_header3", "Überschrift", value = "Vorfälle und Anteil ausländischer MitbürgerInnen", rows = 2, resize = "none") %>%
                           shiny::tagAppendAttributes(style = 'width: 100%;', height = "600"),
                         textAreaInput("context_map_text3", "Beschreibung", value = "Vorfälle rechter Gewalt zusammen mit dem Anteil ausländischer MitbürgerInnen, Quelle: regionalstatistik.de", rows = 7, resize = "none") %>%
                           shiny::tagAppendAttributes(style = 'width: 100%;')
                         
                         # ------------------------------------------------------------------------------
         ), column(width = 9,
                   # rechts:-----------------------------------------------------------------------
                   h3(textOutput("context_map_header3")),
                   plotOutput('context_map3', height = "500"),
                   p(textOutput("context_map_text3"))
                   # ------------------------------------------------------------------------------
         )),
         # foreigner map end ############################################################
         # nsdap map start ############################################################
         fluidRow(column(3,
                         # links: -----------------------------------------------------------------------
                         textAreaInput("context_map_header4", "Überschrift", value = "Vorfälle im historischen Kontext", rows = 2, resize = "none") %>%
                           shiny::tagAppendAttributes(style = 'width: 100%;'),
                         textAreaInput("context_map_text4", "Beschreibung", value = "Vorfälle rechter Gewalt zusammen mit dem Anteil NSDAP Wählender 1933, Quelle: Falter et al 1992", rows = 7, resize = "none") %>%
                           shiny::tagAppendAttributes(style = 'width: 100%;')
                         
                         # ------------------------------------------------------------------------------
         ), column(width = 9,
                   # rechts:-----------------------------------------------------------------------
                   h3(textOutput("context_map_header4")),
                   plotOutput('context_map4', height = "500"),
                   p(textOutput("context_map_text4"))
                   # ------------------------------------------------------------------------------
         )),
         # nsdap map end ############################################################
         
)