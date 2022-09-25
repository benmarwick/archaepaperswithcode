FROM rocker/binder:4.1.0
LABEL maintainer='Ben Marwick'
USER root
RUN R --vanilla -s -e "options(repos = list(CRAN = 'http://cran.rstudio.com'));  install.packages('git2r', 'glue', 'RefManageR', 'rtweet', 'stringr', 'tidyverse')"
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
USER ${NB_USER}


RUN exit 0
