#' main UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList

mod_main_ui <- function(id){
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        fluidPage(
          fluidRow(
            tmap::tmapOutput(ns("map"))),
          fluidRow(
            column(6,
                   HTML("<h6><strong>Select Region(s)</strong></h6>"),
                   shinyWidgets::virtualSelectInput(ns("region"), label = NULL, choices = c("Arctic", "Eastern Pacific", "Southwest Indian Ocean", "Western Pacific"), selected = NULL, multiple = T)),
            column(6,
                   HTML("<h6><strong>Select Country(s)</strong></h6>"),
                   shinyWidgets::virtualSelectInput(ns("country"), label = NULL, choices = list('Arctic' = 'Alaska', "Eastern Pacific" = c('Mexico', 'Colombia', 'Ecuador', 'Peru', 'Chile'), "South-west Indian Ocean" = c('Madagascar', 'Mozambique', 'Tanzania'), "Western Pacific" = c('Papua New Guinea', 'Indonesia', 'Fiji', 'Solomon Islands')), selected = NULL, multiple = T)))),
        width = 6),
      mainPanel(
        fluidPage(
          tabsetPanel(id = "indicator", type = "pills",
                      tabPanel("Nature", value = "Nature", mod_ind_timeseries_ui("ind_timeseries_1", natposindicator_choices = c("Marine Red List", "Marine Living Planet", "Fisheries Stock Condition", "Habitat Condition", "Effective Protection"))),
                      tabPanel("Climate", value = "Climate",
                               #mod_ind_timeseries_ui("ind_timeseries_1", natposindicator_choices = c("Climate Adaptation Plans", "Habitat Carbon Storage", "Carbon Under Effective Protection"))
                               ),
                     tabPanel("People", value = "People",
                              #mod_ind_timeseries_ui("ind_timeseries_1", natposindicator_choices = c("Small Scale Fisheries Rights", "Wealth Relative Index", "Human Development Index"))
                              )
                     )
          ),
        width = 6)
    )
  )
}

#' main Server Functions
#'
#' @noRd
mod_main_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    country <<- reactive({input$country}) # storing in global env b/c don't know of an alternative...TODO fix
    region <<- reactive({input$region})

    mapdat <- reactive({
      if(!is.null(input$region) & !is.null(input$country)){
        countrypolys <- eez |> dplyr::filter(UNION %in% dplyr::filter(country_names, country %in% c(input$country))$country)
        regionpolys <- regions |> dplyr::filter(Region %in% dplyr::filter(region_names, region %in% c(input$region))$region)
        list(countrypolys, regionpolys)
      }else if(!is.null(input$region)){
        regionpolys <- regions |> dplyr::filter(Region %in% dplyr::filter(region_names, region %in% c(input$region))$region)
        list(regionpolys)
      }else if(!is.null(input$country)){
        countrypolys <- eez |> dplyr::filter(UNION %in% dplyr::filter(country_names, country %in% c(input$country))$country)
        list(countrypolys)
      }
    })

    # Sidebar ----------------------------------------------------------
    # Sidebar Map
    output$map <- tmap::renderTmap({
      if(length(mapdat())==0){
        tmap::qtm(regions, borders = NULL)
      }else if(length(mapdat())>1){
        alldat <- rbind(dplyr::select(mapdat()[[2]], geom), dplyr::select(mapdat()[[1]], geom))
        tmap::qtm(mapdat()[[2]], fill = 'Region', polygons.alpha = 0.5, fill.legend.show = F, bbox = sf::st_bbox(alldat)) + tmap::qtm(mapdat()[[1]], fill = 'UNION', polygons.alpha = 0.5, fill.legend.show = F, bbox = sf::st_bbox(alldat))}else if(ncol(mapdat()[[1]])>2){
          tmap::qtm(mapdat()[[1]], fill = 'UNION', polygons.alpha = 0.5, fill.legend.show = F)
        }else if(!is.null(mapdat()[[1]])){
          tmap::qtm(mapdat()[[1]], fill = 'Region', polygons.alpha = 0.5, fill.legend.show = F)
        }
    })

     #Observing tabpanels --------------------------------------------------------------------
    #observeEvent(input$indicator, {
     # if(input$indicator == 'Nature') {
      #  mod_ind_timeseries_server("ind_timeseries_1", input$country, input$region, tabPanel = 'Nature')
      #}#else if(input$indicator == 'Climate') {
       # mod_ind_timeseries_server("ind_timeseries_1", input$country, input$region, tabPanel = 'Climate')
      #}else if(input$indicator == 'People') {
       # mod_ind_timeseries_server("ind_timeseries_1", input$country, input$region, tabPanel = 'People')
      #}
    #})

  })
}

## To be copied in the UI
# mod_main_ui("main_1")

## To be copied in the server
# mod_main_server("main_1")
