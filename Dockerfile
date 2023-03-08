FROM rocker/shiny-verse
RUN apt-get update && apt-get install -y  gdal-bin git-core libcairo2-dev libcurl4-openssl-dev libgdal-dev libgeos-dev libgeos++-dev libgit2-dev libicu-dev libssl-dev libudunits2-dev libxml2-dev make pandoc pandoc-citeproc && rm -rf /var/lib/apt/lists/*
RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'

RUN R -e "install.packages(c('processx', 'testthat', 'attempt', 'jsonlite', 'htmltools', 'hrbrthemes', 'viridis', 'lubridate', 'ggspatial', 'ggrepel', 'wordcloud', 'librarian', 'glue', 'skimr', 'visdat', 'cowplot', 'vroom', 'waiter', 'hexbin', 'sf', 'shinythemes', 'DT', 'golem', 'ggthemes'), repos='https://cloud.r-project.org/')"

RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone
RUN R -e 'remotes::install_local(upgrade="never")'
RUN R -e "install.packages('markdown')"

EXPOSE 3838
#CMD  ["R", "-e", "options('shiny.port'=3838,shiny.host='0.0.0.0');rightwatching::run_app()"]
CMD ["R", "-e", "golem::document_and_reload(); options('shiny.port'=3838,shiny.host='0.0.0.0'); rightwatching::run_app()"]
