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
                      shiny::h5("The Oceans Monitoring, Evaluation, and Learning Dashboard"),
                      shiny::br(),
                      HTML("The code for the dashboard application is available on <a href='https://github.com/cabuelow/OceansDash', target = '_blank'>GitHub</a> as an R package {OceansDash}.
                           If any issues with the dashboard application arise, please log an issue <a href='https://github.com/cabuelow/OceansDash/issues', target ='_blank'>here</a>.
                           If you wish to edit or update the dashboard, you can do so via <a href='https://github.com/cabuelow/OceansDash', target = '_blank'>GitHub</a>; instructions are provided in the <a href='https://rpubs.com/cabuelow/1224376', target ='_blank'>{OceansDash} User Manual</a>."),
                      shiny::br(),
                      shiny::br(),
                      shiny::h5("Indicators"),
                      shiny::br(),
                      HTML("The Marine Red List, Fisheries Stock Condition, Habitat Condition, and Carbon Storage indicators are all sourced from the <a href='https://oceanhealthindex.org/', target ='_blank'>Ocean Health Index</a>. All indicator values are standardised on a scale from 0 to 100, with higher values indicating better status relative to low values. A description of each indicator is provided below."),
                      shiny::br(),
                      shiny::br(),
                      HTML("The Marine Red List indicator is the <a href='https://oceanhealthindex.org/global-scores/goal-scores/biodiversity/species/', target ='_blank'>Ocean Health Index Biodiversity (Species sub-goal) indicator</a>. A high score indicates that most native marine species in a country are not identified as threatened or vulnerable by the IUCN which monitors the status of many species.
"),
                      shiny::br(),
                      shiny::br(),
                      HTML("The Fisheries Stock Condition indicator is the <a href='https://oceanhealthindex.org/global-scores/goal-scores/food-provision/wild-caught-fisheries/', target ='_blank'>Ocean Health Index Food Provision (Wild Caught Fisheries subgoal) indicator</a>. It measures ability to sustainably maximize wild-caught fisheries."),
                      shiny::br(),
                      shiny::br(),
                      HTML("The Habitat Condition indicator is the <a href='https://oceanhealthindex.org/global-scores/goal-scores/biodiversity/habitats/', target ='_blank'>Ocean Health Index Biodiversity (Habitat sub-goal) indicator</a>. This goal assesses the condition of marine habitats that are particularly important in supporting large numbers of marine species. The status of each habitat is its current condition relative to its reference condition, which is based on historical area in the 1980s."),
                      shiny::br(),
                      shiny::br(),
                      HTML("The Carbon Storage indicator is the <a href='https://oceanhealthindex.org/global-scores/goal-scores/carbon-storage/', target = '_blank'>Ocean Health Index Carbon storage indicator</a>. It captures the ability of coastal habitats to store carbon given the amount of carbon they store and their health."),
                      shiny::br(),
                      shiny::br(),
                      HTML("The percentage of ecosystem extent and carbon storage under effective protection are calculated for mangroves, saltmarsh, and coral reef ecosystems (with the exception of carbon storage for coral reefs as global data is not currently available)."),
                      shiny::br(),
                      shiny::br(),
                      HTML("The Marine Living Planet Index measures trends in marine species populations through time. Index values represent the average rate of change in populations from 1970 (the reference year). A value of 1 means the population size is the same as in the reference year, a value less than 1 means population size has decreased, and a value greater than 1 means population size has increased. It is calculated for marine species in each country/region following <a href='https://www.livingplanetindex.org/', target = '_blank'>Living Planet Index</a> methodology."),
                      shiny::br(),
                      shiny::br(),
                      HTML("Small-scale fisheries rights represents the degree of application of a legal/regulatory/policy/institutional framework which recognizes and protects access rights for small-scale fisheries. The indicator score refers to the level of implementation: 1 (lowest) to 5 (highest).
"),
                      shiny::br(),
                      shiny::br(),
                      HTML("The Wealth Relative Index within each country/region was calculated by inverting the Global Gridded Relative Deprivation Index (GRDI; v1 (2010–2020)), which characterizes the relative levels of multidimensional deprivation and poverty at 30 arc-second (~1 km) resolution. A value of 100 represents the highest level of deprivation and a value of 0 the lowest."),
                      shiny::br(),
                      shiny::br(),
                      HTML("The Human Development Index within each country/region was calculated from the 'Gridded global datasets for Gross Domestic Product and Human Development Index' from 1990–2015 at 5 arc-min resolution. The Human Development Index (HDI) is a summary measure of average achievement in key dimensions of human development: a long and healthy life, being knowledgeable and having a decent standard of living. It ranges from 0 (low) to 1 (high)."),
                      shiny::br(),
                      shiny::br(),
                      HTML("Climate Adaptaion Plans (TODO)"),
                      shiny::br(),
                      shiny::br(),
                      shiny::h5("Data sources"),
                      shiny::br(),
                      HTML("Bunting, P., Rosenqvist, A., Hilarides, L., Lucas, R. M., Thomas, N., Tadono, T., Worthington, T. A., Spalding, M., Murray, N. J., & Rebelo, L.-M. (2022). Global Mangrove Extent Change 1996–2020: Global Mangrove Watch Version 3.0. Remote Sensing, 14(15), 3657. https://doi.org/10.3390/rs14153657"),
                      shiny::br(),
                      shiny::br(),
                      HTML("Data from multiple sources compiled by the UN – processed by Our World in Data. “14.b.1 - Degree of application of a legal/regulatory/policy/institutional framework which recognizes and protects access rights for small-scale fisheries (level of implementation: 1 lowest to 5 highest) - ER_REG_SSFRAR” [dataset]. Data from multiple sources compiled by the UN [original data].https://ourworldindata.org/sdgs/life-below-water#sdg-indicator-14-b-1-support-small-scale-fishers"),
                      shiny::br(),
                      shiny::br(),
                      HTML("Center for International Earth Science Information Network - CIESIN - Columbia University. 2022. Global Gridded Relative Deprivation Index (GRDI), Version 1. Palisades, New York: NASA Socioeconomic Data and Applications Center (SEDAC). https://doi.org/10.7927/3xxe-ap97. Accessed 26 August 2024."),
                      shiny::br(),
                      shiny::br(),
                      HTML("Hanson, J. (2022). wdpar: Interface to the World Database on Protected Areas. Journal of Open Source Software, 7: 4594. Available at https://doi.org/10.21105/joss.04594."),
                      shiny::br(),
                      shiny::br(),
                      HTML("Kummu, M., Taka, M., & Guillaume, J. H. A. (2018). Gridded global datasets for Gross Domestic Product and Human Development Index over 1990-2015. Scientific Data, 5. https://doi.org/10.1038/sdata.2018.4"),
                      shiny::br(),
                      shiny::br(),
                      HTML("LPI 2024. Living Planet Index database. 2024. < www.livingplanetindex.org/>. Downloaded on 30 August 2024"),
                      shiny::br(),
                      shiny::br(),
                      HTML("Lyons, M. B., Murray, N. J., Kennedy, E. V., Kovacs, E. M., Castro-Sanguino, C., Phinn, S. R., Acevedo, R. B., Alvarez, A. O., Say, C., Tudman, P., Markey, K., Roe, M., Canto, R. F., Fox, H. E., Bambic, B., Lieb, Z., Asner, G. P., Martin, P. M., Knapp, D. E., … Roelfsema, C. M. (2024). New global area estimates for coral reefs from high-resolution mapping. Cell Reports Sustainability, 100015. https://doi.org/10.1016/j.crsus.2024.100015"),
                      shiny::br(),
                      shiny::br(),
                      HTML("Maxwell, T. L., Hengl, T., Parente, L. L., Minarik, R., Worthington, T. A., Bunting, P., Smart, L. S., Spalding, M. D., & Landis, E. (2023). Global mangrove soil organic carbon stocks dataset at 30 m resolution for the year 2020 based on spatiotemporal predictive machine learning. Data in Brief, 50, 109621. https://doi.org/10.1016/j.dib.2023.109621"),
                      shiny::br(),
                      shiny::br(),
                      HTML("Ocean Health Index. 2024. ohi-global version: Global scenarios data for Ocean Health Index, [August 26, 2024]. National Center for Ecological Analysis and Synthesis, University of California, Santa Barbara. Available at: https://github.com/OHI-Science/ohi-global/releases"),
                      shiny::br(),
                      shiny::br(),
                      HTML("Sanderman, J., Hengl, T., Fiske, G., Solvik, K., Adame, M. F., Benson, L., Bukoski, J. J., Carnell, P., Cifuentes-Jara, M., Donato, D., Duncan, C., Eid, E. M., Ermgassen, P. Z., Lewis, C. J. E., Macreadie, P. I., Glass, L., Gress, S., Jardine, S. L., Jones, T. G., … Landis, E. (2018). A global map of mangrove forest soil carbon at 30 m spatial resolution. Environmental Research Letters, 13(5). https://doi.org/10.1088/1748-9326/aabe1c"),
                      shiny::br(),
                      shiny::br(),
                      HTML("Simard, M., Fatoyinbo, L., Smetanka, C., Rivera-Monroy, V. H., Castañeda-Moya, E., Thomas, N., & Van der Stocken, T. (2019). Mangrove canopy height globally related to precipitation, temperature and cyclone frequency. Nature Geoscience, 12(1), 40–45. https://doi.org/10.1038/s41561-018-0279-1"),
                      shiny::br(),
                      shiny::br(),
                      HTML("Worthington, T. A., Spalding, M., Landis, E., Maxwell, T. L., Navarro, A., Smart, L. S., & Murray, N. J. (2024). The distribution of global tidal marshes from Earth observation data. Global Ecology and Biogeography. https://doi.org/10.1111/geb.13852"),
                      shiny::br(),
                      shiny::br(),
                      HTML("UNEP-WCMC & IUCN. (2024a). Protected Planet: The world database on other effective area-based conservation measures, August 2024."),
                      shiny::br(),
                      shiny::br(),
                      HTML("UNEP-WCMC and IUCN. Https://Www.Protectedplanet.Net/En.
UNEP-WCMC & IUCN. (2024b). Protected planet: The world database on protected areas (WDPA), August 2024.")
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
