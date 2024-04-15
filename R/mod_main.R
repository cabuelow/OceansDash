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
  nsMain <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        fluidPage(
          fluidRow(
            tmap::tmapOutput(nsMain("map"))),
          fluidRow(
            column(6,
                   HTML("<h6><strong>Select Region</strong></h6>"),
                   checkboxGroupInput(nsMain("region"), label = NULL, choices = list("Arctic" = 1, "Eastern Pacific" = 2, "South-west Indian Ocean" = 3, "Western Pacific" = 4), selected = NULL)),
            column(6,
                   HTML("<h6><strong>Select Country</strong></h6>"),
                   checkboxGroupInput(nsMain("country"), label = NULL, choices = Countrylist, selected = NULL)))),
        width = 6),
      mainPanel(
        fluidPage(
          tabsetPanel(id = "indicator", type = "pills",
                      tabPanel("Nature", value = 1,
                               fluidRow(
                                 column(width = 6,
                                        HTML("<h6><strong>Choose Nature Positive Indicator(s)</strong></h6>"),
                                        checkboxGroupInput(nsMain("people"), label = NULL, choices = list("Small Scale Fisheries Rights" = 1, "Wealth Relative Index" = 2, "Human Development Index" = 3), selected = NULL)),
                                 column(width = 6,
                                        HTML("<h6><strong>Display Country baseline and target values?</strong></h6>"),
                                        checkboxInput(nsMain("people_base"), label = "Baseline (year 2020)", value = FALSE),
                                        checkboxInput(nsMain("people_targ"), label = "Target (year 2030)?", value = FALSE)
                                 )),
                               fluidRow(
                                 plotly::plotlyOutput(nsMain('ppl_plot'), width = "100%", height = "650px") |>
                                   shinycssloaders::withSpinner(color="cyan3")),
                                   downloadButton(nsMain('download_dat'), label = 'Data', class = "btn-danger; btn-sm")),
                      tabPanel("People", value = 2,
                               fluidPage()),
                      tabPanel("Climate", value = 3,
                               fluidPage())
          )),
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

    mapdat <- reactive({
      if(!is.null(input$region) & !is.null(input$country)){
        countrypolys <- World |> dplyr::filter(name %in% dplyr::filter(country_names, number %in% c(input$country))$country)
        regionpolys <- regions |> dplyr::filter(Region %in% dplyr::filter(region_names, number %in% c(input$region))$region)
        list(countrypolys, regionpolys)
      }else if(!is.null(input$region)){
        regionpolys <- regions |> dplyr::filter(Region %in% dplyr::filter(region_names, number %in% c(input$region))$region)
        list(regionpolys)
      }else if(!is.null(input$country)){
        countrypolys <- World |> dplyr::filter(name %in% dplyr::filter(country_names, number %in% c(input$country))$country)
        list(countrypolys)
      }else{
        list(World)
      }
    })

    # Sidebar ----------------------------------------------------------
    # Sidebar Map
    output$map <- tmap::renderTmap({
      if(length(mapdat())>1){
        alldat <- rbind(dplyr::select(mapdat()[[2]], geom), dplyr::select(mapdat()[[1]], geom))
        tmap::qtm(mapdat()[[2]], fill = 'Region', polygons.alpha = 0.5, fill.legend.show = F, bbox = sf::st_bbox(alldat)) + tmap::qtm(mapdat()[[1]], fill = 'name', polygons.alpha = 0.5, fill.legend.show = F, bbox = sf::st_bbox(alldat))}else if(ncol(mapdat()[[1]])>2){
          tmap::qtm(mapdat()[[1]], fill = 'name', polygons.alpha = 0.5, fill.legend.show = F)
        }else{
          tmap::qtm(mapdat()[[1]], fill = 'Region', polygons.alpha = 0.5, fill.legend.show = F)
        }
    })

    # Main panel ----------------------------------------------------------

    observeEvent({input$indicator == 1}, {

      indppl <- reactive({
        country_indppl <- indicators |> dplyr::filter(Indicator_category == 'People' & Country %in% dplyr::filter(country_names, number %in% c(input$country))$country & Indicator %in% dplyr::filter(ppl_indnames, number %in% c(input$people))$ind) |> dplyr::mutate(RegionCountry = Country)
        region_indppl <- indicators |> dplyr::filter(Indicator_category == 'People' & Region %in% dplyr::filter(region_names, number %in% c(input$region))$region & Indicator %in% dplyr::filter(ppl_indnames, number %in% c(input$people))$ind) |> dplyr::mutate(RegionCountry = Region)
        baseline <- base_targets |> dplyr::filter(Type == 'Baseline_2020' & Country %in% dplyr::filter(country_names, number %in% c(input$country))$country & Indicator %in% dplyr::filter(ppl_indnames, number %in% c(input$people))$ind)
        targets <- base_targets |> dplyr::filter(Type == 'Target_2030' & Country %in% dplyr::filter(country_names, number %in% c(input$country))$country & Indicator %in% dplyr::filter(ppl_indnames, number %in% c(input$people))$ind)
        indicators <- dplyr::bind_rows(country_indppl, region_indppl)
        if(input$people_base == TRUE && input$people_targ == TRUE && !is.null(input$country)){
          list(indicators, baseline, targets)
        }else if(input$people_base == TRUE && !is.null(input$country)){
          list(indicators, baseline)
        }else if(input$people_targ == TRUE && !is.null(input$country)){
          list(indicators, targets)
        }else{
          list(indicators)
        }
      })

      output$ppl_plot <- plotly::renderPlotly({
        if(nrow(indppl()[[1]])>0){
          if(length(indppl()) == 1){
            ggplot2::ggplot(indppl()[[1]]) + ggplot2::aes(x = Year, y = Value, col = RegionCountry) + ggplot2::geom_point() + ggplot2::geom_smooth() + ggplot2::facet_wrap(~Indicator, ncol = 1, scales = 'free') + ggplot2::ylab('Standardised indicator value') + ggplot2::xlab('Year') + ggplot2::scale_color_manual(values = col_pal) + ggplot2::theme_classic() + ggplot2::theme(text = ggplot2::element_text(size = 20), legend.title = ggplot2::element_blank())}
          else if(length(indppl()) == 2){
            ggplot2::ggplot() + ggplot2::geom_point(data = indppl()[[1]], ggplot2::aes(x = Year, y = Value, col = RegionCountry)) + ggplot2::geom_smooth(data = indppl()[[1]], ggplot2::aes(x = Year, y = Value, col = RegionCountry)) + ggplot2::geom_line(data = indppl()[[2]], ggplot2::aes(x = Year, y = Value, col = Country), size = 2, alpha = 0.5, linetype = 'dashed') + ggplot2::facet_wrap(~Indicator, ncol = 1, scales = 'free') + ggplot2::ylab('Standardised indicator value') + ggplot2::xlab('Year') + ggplot2::scale_color_manual(values = col_pal) + ggplot2::theme_classic() + ggplot2::theme(text = ggplot2::element_text(size = 20), legend.title = ggplot2::element_blank())
          }else if(length(indppl()) == 3){
            ggplot2::ggplot() + ggplot2::geom_point(data = indppl()[[1]], ggplot2::aes(x = Year, y = Value, col = RegionCountry)) + ggplot2::geom_smooth(data = indppl()[[1]], ggplot2::aes(x = Year, y = Value, col = RegionCountry)) + ggplot2::geom_line(data = indppl()[[2]], ggplot2::aes(x = Year, y = Value, col = Country), size = 2, alpha = 0.5, linetype = 'dashed') + ggplot2::geom_line(data = indppl()[[3]], ggplot2::aes(x = Year, y = Value, col = Country), size = 2, alpha = 0.5, linetype = 'dashed') + ggplot2::facet_wrap(~Indicator, ncol = 1, scales = 'free') + ggplot2::ylab('Standardised indicator value') + ggplot2::xlab('Year') + ggplot2::scale_color_manual(values = col_pal) + ggplot2::theme_classic() + ggplot2::theme(text = ggplot2::element_text(size = 20), legend.title = ggplot2::element_blank())
          }
        }
      })

      # Download -------------------------------------------------------
      output$download_dat <- downloadHandler(
        filename = function() {
          paste("data-", Sys.Date(), ".csv", sep="")
        },
        content = function(file) {
          write.csv(indppl()[[1]], file)
        }
      )

    })
  })
  }

## To be copied in the UI
# mod_main_ui("main_1")

## To be copied in the server
# mod_main_server("main_1")
