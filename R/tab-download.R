tabPanel(title = "Download",
         id    = "downloadTab",
         value = "downloadTab",
         icon  = icon("download"),
         #includeMarkdown(file.path("text", "intro.md"))
         includeMarkdown(file.path("inst", "app", "www", "outro.md")),
         fluidRow(
           column(6, 
                  shiny::radioButtons("format", h4("Report Format wählen"), choices =  c("HTML", "Word"),
                                     inline = TRUE), multiple = FALSE),
         column(6, 
                shiny::downloadButton("report", "Datenbericht laden")
                )
          )
)