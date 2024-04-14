
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Oceans Monitoring, Evaluation & Learning Dashboard

The Oceans Dashboard displays indicator time-series data to monitor
progress towards goals for nature, people, and climate.

## Installation

If you wish to run the Oceans Dashboard offline, you can install the
development version from [GitHub](https://github.com/) using:

``` r
devtools::install_github("cabuelow/OceansDash")
```

and run the application using:

``` r
library(OceansDash)
run_app()
```

Please note however, that the above download and installation is not
required if you simply want to use the Oceans Dashboard. The latest
version will always be available on the [Shiny
Server](https://cbuelow.shinyapps.io/oceans-dashboard-prototype_v2/)

## Development TODO

- Finish WWF updates, listed below

- Get data

- Start drafting manual for updating, etc.

**WWF requests**:

Map -\[ \] Change name of basemap layers to Gray Canvas, Street Map,
Topo Map

-\[ \] Add Ocean basemap.

-\[ \] If these features don’t slow down the app, can you add:

MPAs from the WDPA data set (only when countries are selected)

Coastal ecosystems such as mangroves, coral reefs, saltmarshes, seagrass
(when countries are selected)

EEZ when countries are selected.

Select Region and Country -\[ \] Have you tried a dropdown menu to save
room? Not sure what looks better.

Select Region -\[ \] The Arctic selection should only show the Alaska
Artic -\[ \] The Western Pacific should include Fiji and the Solomon
Islands as well besides PNG and Indonesia

Select Country -\[ \] Alaska should be Alaska only, right now it shows
the entire USA. -\[ \] Consider grouping the countries by regions?

People/Climate/Nature -\[ \] Re-arrange tabs to Nature \| People \|
Climate

-\[ \] Group indicators into Seascape Nature Positive Indicator (the
ones you have) and Seascape Core Indicators (to add later)

-\[ \] Not sure about the regional baseline or targets yet, but country
level baseline and targets for sure

-\[ \] Indicators

-\[ \] Could we add tooltips to each indicator with the definition?
Either as a pop-up window or as another column with the explanation and
data source when that specific indicator is selected.

-\[ \] Graphs

-\[ \] Could we add download graph and download data feature for the
entire panel?

-\[ \] Can we add a roll-over feature where the data points show as
tooltip when the user hoover over the graphs (I know this wasn’t
available in ggplot awhile back)

-\[ \] Label target and baseline lines.
