#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @import viridis
#' @import hrbrthemes
#' @import tidyverse
#' @import dplyr
#' @import visdat
#' @import shinythemes
#' @import hexbin
#' @import waiter
#' @import tm
#' @import cowplot
#' @import ggplot2
#' @noRd

#library(shinythemes, hexbin, waiter, dplyr)
app_server <- function( input, output, session ) {
  
  
  username <- Sys.getenv("SHINYPROXY_USERNAME")
  
  Sys.setlocale("LC_TIME","de_DE.UTF-8")
  
  waiting_screen_load <- tagList(
    spin_flower(),
    h4(paste0("Hallo. Das ist eine Demo, ich hole fake Daten.")), 
  ) 
  
  waiting_screen_report <- tagList(
    spin_flower(),
    h4(paste0("Das ist eine Demo, ich baue einen Report aus fake Daten.")), 
  ) 
  
  LoadToEnvironment <- function(RData, env=new.env()) {
    load(RData, env)
    return(env)
  }
  
  session$onSessionEnded(stopApp)
  
  w <- Waiter$new(id = c("context_map2"))
  ## Start Tab Load  #####################################################
  observeEvent(input$load, {
    source(file.path("R", "def_plot.R"),  local = TRUE)
    #show spinner when user clicks on input$load
    waiter_show(html = waiting_screen_load, color = "grey")
    #load the right org file depending on input. this needs to be checked properly: scoping, link to user session, create empty env before loading? 
    load(file.path("data", input$select_org))

    #add filter logic: all following elements will use the filter bounds specified by this function in UI. chornik_filtered is a reactive elements
    updateDateRangeInput(session, "dates", start = min(chronik_enriched$date), end = max(chronik_enriched$date))
    
    chronik_filtered <- reactive(chronik_enriched %>%
                                   dplyr::filter(date >= input$dates[1],
                                          date <= input$dates[2])
                                   )
    output$load_text <- renderUI({
      HTML(paste0("Vorfälle in der Chronik gefunden: ", nrow(chronik), ", diese Analyse nutzt ", nrow(chronik_filtered()), "<br>", 
                  "Davon auf Karte lokalisiert: ", nrow(dplyr::filter(chronik_filtered(), !is.na(lat))), "<br>", 
                  "Vom ", format.Date(min(chronik_filtered()$date), "%d.%m.%Y"), " bis ", format.Date(max(chronik_filtered()$date), "%d.%m.%Y")
      ))
    })
    #here we summarise data, depending on file specified and date range given. all resulting grouped dataframes are reactive elements. 
    source(file.path("R", "summarise.R"),  local = TRUE)
    
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
    ## End Tab Load  #####################################################
    
    
    
    ## Start Tab Visualize  #####################################################
    # Start of barchart  #####################################################
    output$barchart_header1 <- renderText({ input$barchart_header1 })
    output$barchart <- renderPlot({
      make_barchart(data = chronik_filtered(), level = input$barchart_option1)
    })
    output$barchart_text1 <- renderText({ input$barchart_text1 })
    # End of barchart############################################################
    
    # Start of county_timeline   #####################################################
    output$county_timeline_header1 <- renderText({ input$county_timeline_header1 })
    #reactive graph: rdata file -> date1&date2 -> chronik_filtered -> summarised into chornik_by_county. we observe for changes in the latter to adjust allowed select values 
    observeEvent(chronik_by_county(), {
      updateSelectInput(session, "county_timeline_option1", choices = unique(chronik_by_county()$admin6), selected = unique(chronik_by_county()$admin6)) 
    })
    output$county_timeline <- renderPlot({
      #show a message instead of plot when no input selected
      validate(
        need(input$county_timeline_option1, 'Bitte mindestens einen Landkreis aussuchen!')
      )
      make_county_timeline(data = chronik_by_county(), selected_kreise = input$county_timeline_option1) 
    })
    output$county_timeline_text1 <- renderText({ input$county_timeline_text })
    # End of county_timeline############################################################
    ## End Tab Visualize  #####################################################
    
    
    ## Start Tab Contextualize  #####################################################
    output$context_map_header1 <- renderText({ input$context_map_header1 })
    output$context_map_option1 <- renderUI({
      selectInput("context_map_option2", "Partei auswählen",unique(dplyr::filter(votes_data, PART04 != "GESAMT")$PART04))})
    output$context_map1 <- renderPlot({make_context_map1(party = input$context_map_option2)})
    output$context_map_text1 <- renderText({ input$context_map_text1 })
    
    output$context_map_header2 <- renderText({ input$context_map_header2 })
    output$context_map2 <- renderPlot({
      w$show()
      make_context_map2()})
    output$context_map_text2 <- renderText({ input$context_map_text2 })
    
    output$context_map_header3 <- renderText({ input$context_map_header3 })
    output$context_map3 <- renderPlot({make_context_map3()})
    output$context_map_text3 <- renderText({ input$context_map_text3 })
    
    output$context_map_header4 <- renderText({ input$context_map_header4 })
    output$context_map4 <- renderPlot({make_context_map4()})
    output$context_map_text4 <- renderText({ input$context_map_text4 })
    ## End Tab Contextualize  #####################################################
    
    
    ## Start Tab Verify  #####################################################
    
    # Start of source_multiple map  #####################################################
    output$missing_table_header1 <- renderText({ input$missing_table_header1 })
    chronik_missing <- reactive(chronik_filtered() %>%
                                  filter(is.na(lat) | is.na(lon)))
    output$missing_table <- shiny::renderDataTable(
                              chronik_missing(), 
                              options = list(pageLength = 5, autoWidth = FALSE), escape = FALSE)

    output$missing_plot <- renderPlot({
      make_missing_plot()
    })
    output$missing_table_text1 <- renderText({ input$missing_table_text1 })
    # End of source_map############################################################
    
    # Start of source_multiple map  #####################################################
    output$source_multiple_header1 <- renderText({ input$source_multiple_header1 })
    output$source_multiple_map <- renderPlot({
      make_source_multiple_map()
    })
    output$source_multiple_text1 <- renderText({ input$source_multiple_text1 })
    # End of source_map############################################################
    
    # Start of source_map map  #####################################################
    output$source_map_header1 <- renderText({ input$source_map_header1 })
    source_map_choices <- unique(chronik_enriched$source_group)
    updateSelectInput(session, "source_map_option1", choices = source_map_choices) 
    output$source_map <- renderPlot({
      make_source_map()
    })
    output$source_map_text1 <- renderText({ input$source_map_text1 })
    # End of source_map############################################################
    
    # Start of source_wordcloud  #####################################################
    output$source_wordcloud_header1 <- renderText({ input$source_wordcloud_header1 })
    output$source_wordcloud <- renderPlot({
      wordcloud::wordcloud(words = filter(chronik_enriched, source_group == input$source_map_option1)$source_name, min.freq = 1)
    })
    output$source_wordcloud_text1 <- renderText({ input$source_wordcloud_text1 })
    # End of source_wordcloud############################################################
    
    
    
    ## End Tab Verify  #####################################################
    
    
    ## Start Tab Download  #####################################################
    output$report <- downloadHandler(
      validate(
        need(input$county_timeline_option1, 'Bitte mindestens einen Landkreis aussuchen im Tab <b>Daten darstellen</b>!')
      ),
      # For PDF output, change this to "report.pdf"
      filename = function() {
        paste('report', sep = '.', switch(
          input$format, PDF = 'pdf', HTML = 'html', Word = 'docx'
        ))
      },
      content = function(file) {
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed).
        
        tempReport <- file.path(tempdir(), "report.Rmd")
        file.copy(file.path("inst", "app", "www", "report.Rmd"), tempReport, overwrite = TRUE)
        
        waiter_show(html = waiting_screen_report, color = "grey")
        library(rmarkdown)
        render(tempReport,
               output_file = file, 
               switch(input$format,
                      PDF = pdf_document(), 
                      HTML = html_document(), 
                      Word = word_document()
        ))
        waiter_hide()
      }
    )
    ## End Tab Download  #####################################################
    waiter_hide()
    
    #closing load action block
  })
}
