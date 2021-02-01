tabPanel(title = "Daten laden",
         id    = "loadTab",
         value = "loadTab",
         icon  = icon("table"),
         fluidRow(
                column(2, 
                       shiny::selectInput("select_org", h4("Bundesland auswählen"), choices = list.files(file.path("data"), pattern = "*.RData"), multiple = FALSE)),
                column(2, 
                       shiny::actionButton("load", "Daten holen")),
                column(3, 
                        shiny::dateRangeInput("dates", h4("Analysezeitraum wählen"), start = NULL, end = NULL)),
                column(3, 
                        shiny::htmlOutput("load_text")),
                column(2, 
                       shiny::downloadButton("download_data", "Download Tabelle in .tsv"))
        ),
         shiny::dataTableOutput("table1")
)
