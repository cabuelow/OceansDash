#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd

app_server <- function(input, output, session) {
  # Your application server logic

  # Observing navbar --------------------------------------------------------------------
  observeEvent(input$navbar, {
    if(input$navbar == "Main") {
      mod_main_server("main_1")
    }
  })
}
