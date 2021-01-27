#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @import dplyr
#' @import ggspatial
#' @import ggplot2
#' @import viridis
#' @noRd
app_server <- function( input, output, session ) {
  
  
  username <- Sys.getenv("SHINYPROXY_USERNAME")
  
  Sys.setlocale("LC_TIME","de_DE.UTF-8")
  
  waiting_screen <- tagList(
    spin_flower(),
    h4(paste0("Hallo ", username, ", ich hole Daten")), 
  ) 
  
  LoadToEnvironment <- function(RData, env=new.env()) {
    load(RData, env)
    return(env)
  }
  
  session$onSessionEnded(stopApp)
  
  w <- Waiter$new(id = c("context_map"))
  ## Start Tab Load  #####################################################
  observeEvent(input$load, {
    source(file.path("R", "def_plot.R"),  local = TRUE)
    #show spinner when user clicks on input$load
    waiter_show(html = waiting_screen, color = "grey")
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
      updateSelectInput(session, "county_timeline_option1", choices = unique(chronik_by_county()$admin6)) 
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
    output$context_map_option2 <- renderUI({
      req(input$context_map_option1 == "Wahlergebnisse")
      selectInput("context_map_option3", "Partei auswählen",
                  unique(dplyr::filter(votes_data, PART04 != "GESAMT")$PART04)
      )
    })
    
    output$context_map <- renderPlot({
      if (input$context_map_option1 == "Wahlergebnisse") {
        kreise %>%
          left_join(select(
            filter(votes_data, PART04 == input$context_map_option3), id, vote_percentage), 
            by = c("AGS_KREIS_ID" = "id")) -> kreise
        
        make_context_map() +
          geom_sf(data = kreise, aes(geometry = geometry, alpha = vote_percentage), fill = "orange") +
          #stat_bin_hex(data = chronik_enriched, aes(x = lon, y = lat, fill = ..count..), alpha = 0.9, binwidth = 0.05) +
          geom_point(data = chronik_by_place(), aes(x = lon, y = lat, size = n), fill = "black", color = "grey20") +
          scale_fill_viridis(option = "cividis", direction = -1) +
          labs(size = "Vorfälle laut Chronik", alpha = paste0(input$context_map_option3, " WählerInnen, %"))
      }
      else if (input$context_map_option1 == "Bevölkerung") {
        w$show()
        make_context_map(baselayer = kreise) +
          geom_sf(data = pop2011_filtered, aes(alpha = TOT_P), fill = "Blue", lwd=0) +
          stat_bin_hex(data = chronik_filtered(), aes(x = lon, y = lat, fill = ..count..), alpha = 0.8, binwidth = 0.05) +
          scale_fill_viridis(option = "C", name = "Vorfälle laut Chronik", direction = -1) +
          labs(alpha = "Bevölkerungsdichte")
        #w$hide()
      }
      else if (input$context_map_option1 == "AusländerInnen-Anteil") {
        make_context_map() +
          geom_sf(data = kreise, aes(geometry = geometry, fill = NATA_percentage)) +
          #stat_bin_hex(data = chronik_enriched, aes(x = lon, y = lat, fill = ..count..), alpha = 0.9, binwidth = 0.05) +
          geom_point(data = chronik_by_place(), aes(x = lon, y = lat, size = n), fill = "black", color = "grey20") +
          scale_fill_viridis(option = "cividis", direction = -1) +
          labs(size = "Vorfälle laut Chronik", fill = "% AusländerInnen")
      }
      else if (input$context_map_option1 == "NSDAP-WählerInnen 1933") {
        pt1 <- make_context_map() +
          geom_sf(data = kreise, aes(geometry = geometry)) +
          geom_point(data = chronik_by_place(), aes(x = lon, y = lat, size = n), fill = "black", color = "grey20") +
          labs(size = "Vorfälle rechter Gewalt")
        pt2 <- make_historic_map() 
        
        cowplot::plot_grid(pt1, pt2, align = "h")
      }
    })
    output$context_map_text1 <- renderText({ input$context_map_text1 })
    ## End Tab Contextualize  #####################################################
    
    
    ## Start Tab Verify  #####################################################
    
    # Start of source_multiple map  #####################################################
    output$source_multiple_header1 <- renderText({ input$source_multiple_header1 })
    output$source_multiple <- renderPlot({
      make_context_map(baselayer = kreise) +
        geom_jitter(data = chronik_filtered(), aes(x = lon, y = lat, color = source_group, group=source_group), width = 0.05, height = 0.05, size = 0.7) +
        #scale_color_manual(values = c("black", "#1B9E77"), name="Kontaktaufname") +
        #geom_label_repel(data = labels, aes(x = longitude_to, y = latitude_to, label = label), nudge_x = 10) +
        coord_sf() +
        labs(caption = "Punkte sind hier nicht genau auf dem Ort des Vorfalls") + 
        facet_wrap(~source_group) + 
        theme_transparent() + 
        theme(legend.position = "right")
    })
    output$source_multiple_text1 <- renderText({ input$source_multiple_text1 })
    # End of source_map############################################################
    
    # Start of source_map map  #####################################################
    output$source_map_header1 <- renderText({ input$source_map_header1 })
    source_map_choices <- unique(chronik_enriched$source_group)
    updateSelectInput(session, "source_map_option1", choices = source_map_choices) 
    output$source_map <- renderPlot({
      ggplot() +
        geom_sf(data = kreise, aes(geometry = geometry), fill = "grey60") +
        stat_bin_hex(data = chronik_enriched, aes(x = lon, y = lat), alpha = 0.9, binwidth = 0.05) +
        scale_fill_viridis(option = "inferno", direction = -1, name = "Vorfälle in Chronik") +
        geom_point(data = filter(chronik_by_source_place(), source_group == input$source_map_option1), aes(x = lon, y = lat, size = n), fill = "black") +
        coord_sf() +
        labs(size = input$source_map_option1) +
        theme_transparent()	
      
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
    
    waiter_hide()
    #closing load action block
  })
}
