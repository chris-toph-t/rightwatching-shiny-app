FROM rocker/geospatial:4.0.3

MAINTAINER Rightwatching "info@rightwatching.org"

WORKDIR /srv/prepare/

# install dependencies of the app
RUN R -e "install.packages(c('jsonlite', 'osmdata', 'htmltools', 'rvest', 'xml2', 'httr', 'tryCatchLog', 'futile.logger', 'hrbrthemes', 'viridis', 'lubridate', 'ggspatial', 'quanteda', 'ggrepel', 'wordcloud', 'librarian', 'tm'), repos='https://cloud.r-project.org/')"

RUN R -e "librarian::shelf(CorrelAid/datenguideR, dieghernan/giscoR)"

#for dates, give proper locale
RUN locale-gen de_DE.UTF-8 && \
    update-locale

#run scripts with nonroot users. rstudio user already set up in rocker images
RUN chown -R rstudio:rstudio /srv/

#copy prep scripts to container workdir
#COPY ./ ./

USER rstudio

#define what to run when container starts: the full prepare script is launched
CMD Rscript --verbose /srv/prepare/prepare.R