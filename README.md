
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rightwatching

<!-- badges: start -->

<!-- badges: end -->

The goal of rightwatching is to help small watchdogs keeping track of
developments in right-wing violence.

## Using as Docker app

rightwatching is a dockerized shiny app. Currently the app depends on
RData files in the data directory. This will be replaced by dynamic API
calls.

  - cd into this directory and build with `docker build . -t
    rightwatching-shiny-app`. This will take a long time at first run.
  - this container does not need to be run manually, it should be called
    from shinyproxy (needs to be specified in application.yml of
    shinyproxy)
  - For testing, it an be run manually. It will expose shiny app on port
    3838. Use docker logs name\_of\_container for debugging
      - run manually like this: docker run -p 3838:3838 -v
        /home/christopherus/rechtsaussen-shiny-app/data/:/srv/data/ -v
        /home/christopherus/rechtsaussen-shiny-app/prepare/:/srv/prepare/
        rightwatching-shiny-app

## Using as package
