FROM rocker/r-ver:4.0.3
RUN apt-get update && apt-get install -y  gdal-bin git-core libcairo2-dev libcurl4-openssl-dev libgdal-dev libgeos-dev libgeos++-dev libgit2-dev libicu-dev libssl-dev libudunits2-dev libxml2-dev make pandoc pandoc-citeproc && rm -rf /var/lib/apt/lists/*
RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN R -e 'remotes::install_github("r-lib/remotes", ref = "97bbf81")'
RUN Rscript -e 'remotes::install_version("glue",upgrade="never", version = "1.4.2")'
RUN Rscript -e 'remotes::install_version("htmltools",upgrade="never", version = "0.5.0")'
RUN Rscript -e 'remotes::install_version("processx",upgrade="never", version = "3.4.4")'
RUN Rscript -e 'remotes::install_version("testthat",upgrade="never", version = "3.0.0")'
RUN Rscript -e 'remotes::install_version("attempt",upgrade="never", version = "0.3.1")'
RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.5.0")'
RUN Rscript -e 'remotes::install_version("config",upgrade="never", version = "0.3.1")'
RUN Rscript -e 'remotes::install_version("tidyverse",upgrade="never", version = "1.3.0")'
RUN Rscript -e 'remotes::install_version("cowplot",upgrade="never", version = "1.1.1")'
RUN Rscript -e 'remotes::install_version("vroom",upgrade="never", version = "1.3.2")'
RUN Rscript -e 'remotes::install_version("tm",upgrade="never", version = "0.7-8")'
RUN Rscript -e 'remotes::install_version("waiter",upgrade="never", version = "0.2.0")'
RUN Rscript -e 'remotes::install_version("hexbin",upgrade="never", version = "1.28.2")'
RUN Rscript -e 'remotes::install_version("viridis",upgrade="never", version = "0.5.1")'
RUN Rscript -e 'remotes::install_version("sf",upgrade="never", version = "0.9-6")'
RUN Rscript -e 'remotes::install_version("ggrepel",upgrade="never", version = "0.8.2")'
RUN Rscript -e 'remotes::install_version("hrbrthemes",upgrade="never", version = "0.8.0")'
RUN Rscript -e 'remotes::install_version("shinythemes",upgrade="never", version = "1.2.0")'
RUN Rscript -e 'remotes::install_version("DT",upgrade="never", version = "0.16")'
RUN Rscript -e 'remotes::install_version("golem",upgrade="never", version = "0.2.1")'
RUN Rscript -e 'remotes::install_version("ggspatial",upgrade="never", version = "1.1.4")'
RUN locale-gen de_DE.UTF-8 && \
    update-locale
RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone
RUN R -e 'remotes::install_local(upgrade="never")'
EXPOSE 3838
CMD  ["R", "-e", "options('shiny.port'=3838,shiny.host='0.0.0.0');rightwatching::run_app()"]
