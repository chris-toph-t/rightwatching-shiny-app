#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinythemes
#' @import waiter
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    tags$head(HTML(
      "<script>
  var _paq = window._paq = window._paq || [];
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var u='https://matomo.datenlabor.eu/';
    _paq.push(['setTrackerUrl', u+'matomo.php']);
    _paq.push(['setSiteId', '5']);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
  })();
</script>"
        
        
      
    )),
    # List the first level UI elements here 
    fluidPage(
      use_waiter(),
      use_waitress(),
      navbarPage(theme=shinytheme("paper"),
                 title = tags$b("Rechte Gewalt Datenreport"),
                 windowTitle = "Rechte Gewalt Datenreport",
                 id = "mainNavbar",
                 source(file.path("R", "tab-intro.R"),  local = TRUE)$value,
                 source(file.path("R", "tab-load.R"),  local = TRUE)$value,
                 source(file.path("R", "tab-visualize.R"),  local = TRUE)$value,
                 source(file.path("R", "tab-contextualize.R"),  local = TRUE)$value,
                 source(file.path("R", "tab-verify.R"),  local = TRUE)$value,
                 source(file.path("R", "tab-download.R"),  local = TRUE)$value
                 
      )
      
    )
  )
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
 
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'rightwatching'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

