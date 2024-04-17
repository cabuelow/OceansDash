#' ind_timeseries UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_ind_timeseries_ui <- function(id, natposindicator_choices){
  ns <- NS(id)
  tagList(
    fluidRow(
      column(width = 6,
             HTML("<h6><strong>Choose Nature Positive Indicator(s)</strong></h6>"),
             shinyWidgets::virtualSelectInput(ns("natpos_indicator"), label = NULL,
                                              choices = natposindicator_choices,
                                              selected = natposindicator_choices, multiple = T)),
      column(width = 6,
             HTML("<h6><strong>Display Country baseline and target values?</strong></h6>"),
             checkboxInput(ns("base"), label = "Baseline (year 2020)", value = FALSE),
             checkboxInput(ns("targ"), label = "Target (year 2030)", value = FALSE),
      )),
    fluidRow(
      span(textOutput(ns('text')), style="color:red"),
      plotly::plotlyOutput(ns('plot'), width = "100%", height = "650px") |>
        shinycssloaders::withSpinner(color="#0dc5c1")),
    downloadButton(ns('download_dat'), label = 'Data', class = "btn-danger; btn-sm")
  )
}

#' ind_timeseries Server Functions
#'
#' @noRd
mod_ind_timeseries_server <- function(id, country, region){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    ind <- reactive({
      country_ind <- indicators |> dplyr::filter(Indicator_category == 'Nature' & Country %in% dplyr::filter(country_names, country %in% c(country()))$country & Indicator %in% dplyr::filter(indnames, text %in% c(input$natpos_indicator))$ind) |> dplyr::mutate(RegionCountry = Country)
      region_ind <- indicators |> dplyr::filter(Indicator_category == 'Nature' & Region %in% dplyr::filter(region_names, region %in% c(region()))$region & Indicator %in% dplyr::filter(indnames, text %in% c(input$natpos_indicator))$ind) |> dplyr::mutate(RegionCountry = Region)
      baseline <- base_targets |> dplyr::filter(Type == 'Baseline_2020' & Country %in% dplyr::filter(country_names, country %in% c(country()))$country & Indicator %in% dplyr::filter(indnames, text %in% c(input$natpos_indicator))$ind)
      targets <- base_targets |> dplyr::filter(Type == 'Target_2030' & Country %in% dplyr::filter(country_names, country %in% c(country()))$country & Indicator %in% dplyr::filter(indnames, text %in% c(input$natpos_indicator))$ind)
      indicators <- dplyr::bind_rows(country_ind, region_ind)
      if(input$base == TRUE && input$targ == TRUE && !is.null(country())){
        list(indicators, baseline, targets)
      }else if(input$base == TRUE && !is.null(country())){
        list(indicators, baseline)
      }else if(input$targ == TRUE && !is.null(country())){
        list(indicators, targets)
      }else{
        list(indicators)
      }
    })

    output$text <- renderText({
      if(nrow(ind()[[1]])==0){'Please choose Region(s) or Country(s) from panels on the left and Indicators to display from above'}
    })

    output$plot <- plotly::renderPlotly({
      if(nrow(ind()[[1]])>0){
        if(length(ind()) == 1){
          ggplot2::ggplot(ind()[[1]]) + ggplot2::aes(x = Year, y = Value, col = RegionCountry) + ggplot2::geom_point() + ggplot2::geom_smooth() + ggplot2::facet_wrap(~Indicator, ncol = 1, scales = 'free') + ggplot2::ylab('Standardised indicator value') + ggplot2::xlab('Year') + ggplot2::scale_color_manual(values = col_pal, name = NULL) + ggplot2::theme_classic() + ggplot2::theme(text = ggplot2::element_text(size = 13))}
        else if(length(ind()) == 2){
          ggplot2::ggplot() + ggplot2::geom_point(data = ind()[[1]], ggplot2::aes(x = Year, y = Value, col = RegionCountry)) + ggplot2::geom_smooth(data = ind()[[1]], ggplot2::aes(x = Year, y = Value, col = RegionCountry)) + ggplot2::geom_line(data = ind()[[2]], ggplot2::aes(x = Year, y = Value, col = Country), size = 2, alpha = 0.5, linetype = 'dashed') + ggplot2::facet_wrap(~Indicator, ncol = 1, scales = 'free') + ggplot2::ylab('Standardised indicator value') + ggplot2::xlab('Year') + ggplot2::scale_color_manual(values = col_pal, name = NULL) + ggplot2::theme_classic() + ggplot2::theme(text = ggplot2::element_text(size = 13))
        }else if(length(ind()) == 3){
          ggplot2::ggplot() + ggplot2::geom_point(data = ind()[[1]], ggplot2::aes(x = Year, y = Value, col = RegionCountry)) + ggplot2::geom_smooth(data = ind()[[1]], ggplot2::aes(x = Year, y = Value, col = RegionCountry)) + ggplot2::geom_line(data = ind()[[2]], ggplot2::aes(x = Year, y = Value, col = Country), size = 2, alpha = 0.5, linetype = 'dashed') + ggplot2::geom_line(data = ind()[[3]], ggplot2::aes(x = Year, y = Value, col = Country), size = 2, alpha = 0.5, linetype = 'dashed') + ggplot2::facet_wrap(~Indicator, ncol = 1, scales = 'free') + ggplot2::ylab('Standardised indicator value') + ggplot2::xlab('Year') + ggplot2::scale_color_manual(values = col_pal, name = NULL) + ggplot2::theme_classic() + ggplot2::theme(text = ggplot2::element_text(size = 13))
        }
      }
    })

    # Download -------------------------------------------------------
    output$download_dat <- downloadHandler(
      filename = function() {
        paste("data-", Sys.Date(), ".csv", sep="")
      },
      content = function(file) {
        write.csv(ind()[[1]], file)
      }
    )

  })
}

## To be copied in the UI
# mod_ind_timeseries_ui("ind_timeseries_1")

## To be copied in the server
# mod_ind_timeseries_server("ind_timeseries_1")
