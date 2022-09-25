FROM rocker/binder:4.0.2
LABEL maintainer='Ben Marwick'
USER root
<<<<<<< HEAD
=======
RUN R --vanilla -s -e "options(repos = list(CRAN = 'http://cran.rstudio.com'));  install.packages('git2r', 'glue', 'RefManageR', 'rtweet', 'stringr', 'tidyverse')"
>>>>>>> 34d0ba70848baf28cc5dd0c55597f0cb808c6606
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
USER ${NB_USER}

<<<<<<< HEAD
## run any install.R script we find
RUN if [ -f install.R ]; then R --quiet -f install.R; fi
=======

RUN exit 0
>>>>>>> 34d0ba70848baf28cc5dd0c55597f0cb808c6606
