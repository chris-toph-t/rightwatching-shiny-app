#' load_data UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @import dplyr
#' @import waiter
mod_load_data_ui <- function(id){
  ns <- NS(id)
    shiny::tabPanel(title = "Daten laden",
                    id    = ns("loadTab"),
                    value = "loadTab",
                    icon  = icon("table"),
                    fluidRow(
                      column(2, 
                             shiny::selectInput(ns("select_org"), h4("Bundesland auswählen"), choices = list.files(file.path("data"), pattern = "*.RData"), multiple = FALSE)),
                      column(3, 
                             shiny::dateRangeInput(ns("dates"), h4("Analysezeitraum wählen"), start = NULL, end = NULL)),
                      column(2, 
                             shiny::actionButton(ns("load"), "Daten holen")),
                      column(3, 
                             shiny::htmlOutput(ns("load_text"))),
                      column(2, 
                             shiny::downloadButton(ns("download_data"), "Download Tabelle in .tsv"))
                    ),
                    shiny::dataTableOutput(ns("table1"))
    )
    
}
    
#' load_data Server Function
#'
#' @noRd 
mod_load_data_server <- function(input, output, session){
  ns <- session$ns
  waiting_screen <- tagList(
    spin_flower(),
    h4(paste0("Hallo ", ", ich hole Daten")), 
  ) 
        ## Start Tab Load  #####################################################
        observeEvent(input$load, {
          #show spinner when user clicks on input$load
          #waiter::waiter_show(html = waiting_screen, color = "grey")
          #load the right org file depending on input. this needs to be checked properly: scoping, link to user session, create empty env before loading? 
          load(file.path("data", input$select_org))
          
          #add filter logic: all following elements will use the filter bounds specified by this function in UI. chornik_filtered is a reactive elements
          updateDateRangeInput(session, "dates", start = min(chronik_enriched$date), end = max(chronik_enriched$date))
          
          chronik_filtered <- reactive(chronik_enriched %>%
                                         filter(date >= input$dates[1],
                                                date <= input$dates[2]
                                         ))
          output$load_text <- renderUI({
            HTML(paste0("Vorfälle in der Chronik gefunden: ", nrow(chronik), ", diese Analyse nutzt ", nrow(chronik_filtered()), "<br>", 
                        "Davon auf Karte lokalisiert: ", nrow(filter(chronik_filtered(), !is.na(lat))), "<br>", 
                        "Vom ", format.Date(min(chronik_filtered()$date), "%d.%m.%Y"), " bis ", format.Date(max(chronik_filtered()$date), "%d.%m.%Y")
            ))
          })

          output$download_data <- downloadHandler(
            filename = function() {
              paste0(input$load, "_", input$dates[1], "_", input$dates[2], ".tsv")
            },
            content = function(file) {
              vroom::vroom_write(chronik_filtered(), file)
            }
          )
          
          output$table1 = shiny::renderDataTable(
           chronik_filtered(), escape = TRUE
          )
          source(file.path("R", "mod_load_data_fct_summarise.R"),  local = TRUE)
          
          
        }
        )
  }
      
        ## End Tab Load  #####################################################    
    
## To be copied in the UI
# mod_load_data_ui("load_data_ui_1")
    
## To be copied in the server
# callModule(mod_load_data_server, "load_data_ui_1")
 
