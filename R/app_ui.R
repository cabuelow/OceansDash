#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd

app_ui <- function(request) {
  # Your application UI logic
  navbarPage(golem_add_external_resources(), # Leave this function for adding external resources
             id = "navbar",
             title = span(img(src = "www/wwf-logo.jpeg", style="padding-right:5px", height = 40), "Oceans MEL Dashboard"),
             windowTitle = "Oceans MEL Dashboard",
             theme = bslib::bs_theme(version = 5,
                                     bootswatch = "flatly",
                                     "border-width" = "0px",
                                     "enable-rounded" = TRUE), #https://rstudio.github.io/bslib/articles/bslib.html#custom
             selected = "Main",
             tabPanel("Main",
                      mod_main_ui("main_1")),
             tabPanel("Information",
                      HTML('To be decided if this tab panel is necessary')))
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "OceansDash"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
