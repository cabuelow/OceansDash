
<!-- README.md is generated from README.Rmd. If that is this file, please go ahead and edit then knit. If it isn't then DON'T edit - only edit the README.Rmd -->

# Oceans Monitoring, Evaluation & Learning Dashboard

The Oceans Dashboard displays indicator time-series data to monitor
progress towards goals for nature, people, and climate.

## [Installation](#installation) \| [Instructions for contributing](#instructions-for-contributing) \| [Navigating and editing OceansDash](#navigating-and-editing-oceansdash)

## Installation

If you wish to run the Oceans Dashboard offline, you can install the
development version from Github using:

``` r
devtools::install_github("cabuelow/OceansDash", build_vignettes = TRUE)
```

run the application using:

``` r
library(OceansDash)
run_app()
```

and access the user manual:

``` r
vignette('User_Manual', package ='OceansDash')
```

The user manual vignette is also published
[here](https://rpubs.com/cabuelow/1224376) for easy access.

The above download and installation is not required if you simply want
to use the Oceans Dashboard. The latest version is available on the
[Shiny Server](https://cbuelow.shinyapps.io/OceansDash/)

## Instructions for contributing

To contribute to the development of this web application please follow
these instructions:

1.  [Fork and clone](https://happygitwithr.com/fork-and-clone) the
    github repository
2.  Start a new [development
    branch](https://happygitwithr.com/git-branches.html?q=branch#create-a-new-branch)
3.  Make edits to scripts and files - pull, commit and push regularly to
    your development branch. [See below information on navigating the R
    package to make edits](#navigating-and-editing-oceansdash)
4.  When your edits are complete, make a [pull
    request](https://happygitwithr.com/pr-extend.html?q=pull%20request#pr-extend)
    and merge if there are no conflicts.

## Navigating and editing OceansDash

If you are further developing {OceansDash}, start by:

1.  Opening your local {OceansDash} github repo by double-clicking on
    the .Rproj file `OceansDash.Rproj`

2.  Opening the **‘dev/02_dev.R’** script.

- This is where you can:
  - 1)  add packages,
  - 2)  add modules, and
  - 3)  add ‘business’ logic (as opposed to application logic) in the
        form of of functions (add_fct) or utilities (add_utils) - the
        latter being smaller functions that will be used several times.
        [Read more
        here](https://engineering-shiny.org/build-app-golem.html)

3.  Opening the **‘data-raw/make-sysdata.R’** script.

- Here you can import and wrangle data to be used internally by the app.
  Make sure to add it to the ‘sysdata.rda’ at the bottom of the script.
  Run through all lines of code in the script to update all internal
  datasets and overwrite the current ‘sysdata.rda’.

4.  Opening the **‘R/’** folder.

- Here you will find the following R scripts and files:
  - 1)  The `app_ui.R` and `app_server.R` files that serve to provide
        the main app structure and integrate modules,
  - 2)  Any modules (aka ‘sub-apps’, e.g., `mod_main.R`), and
  - 3)  The `sysdata.rda` file created via Step 2 above

5.  Once you have made changes to any of the above, you can run the
    development version of the app via:

``` r
golem::run_dev()
```

6.  If you want to deploy the app to a shinyapps.io server, run the
    development version as above and click the ‘Publish’ or ‘Re-publish’
    button on the top right corner of the app as it is running.

*Note that there are many other files in the {OceansDash} package that
are not discussed here. Those not mentioned are not necessary for
editing or updating the dashboard application, but you can find more
information on what they do/how to use them
[here](https://engineering-shiny.org/build-app-golem.html)*.

## Tips and Tricks

- Declare packages that functions belong to explicitly with `::`,
  e.g. `dplyr::mutate` or you will get an error message saying that the
  function cannot be found.
