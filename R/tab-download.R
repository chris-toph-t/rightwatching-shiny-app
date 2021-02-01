tabPanel(title = "Download",
         id    = "downloadTab",
         value = "downloadTab",
         icon  = icon("download"),
         #includeMarkdown(file.path("text", "intro.md"))
         fluidRow(
           column(6, 
                  shiny::radioButtons("format", h4("Report Format wählen"), choices =  c("PDF", "HTML", "Word"),
                                     inline = TRUE), multiple = FALSE),
         column(6, 
                shiny::downloadButton("report", "Datenbericht laden")
                )
          )
)