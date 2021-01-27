#' visualize UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_visualize_ui <- function(id){
  ns <- NS(id)
  shiny::tabPanel(title = "Daten darstellen & beschreiben",
           id    = ns("visualizeTab"),
           value = "visualizeTab",
           icon  = icon("bar-chart"),
           # barchart start ############################################################'
           fluidRow(column(3,
                           # links: -----------------------------------------------------------------------
                           textAreaInput(ns("barchart_header1"), "Überschrift", value = "Verlauf", rows = 2, resize = "none") %>%
                             shiny::tagAppendAttributes(style = 'width: 100%;'),
                           selectInput(ns("barchart_option1"), "Zeitfenster",
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
}
    
#' visualize Server Function
#'
#' @noRd 
mod_visualize_server <- function(input, output, session){
  ns <- session$ns
 
}
    
## To be copied in the UI
# mod_visualize_ui("visualize_ui_1")
    
## To be copied in the server
# callModule(mod_visualize_server, "visualize_ui_1")
 
