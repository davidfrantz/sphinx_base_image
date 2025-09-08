# This file builds a Docker base image for its use in other projects

# Copyright (C) 2020-2024 Gergely Padányi-Gulyás (github user fegyi001),
#                         David Frantz
#                         Fabian Lehmann
#                         Wilfried Weber

FROM ubuntu:24.04 AS builder

# disable interactive frontends
ENV DEBIAN_FRONTEND=noninteractive 

# Refresh package list & upgrade existing packages 
RUN apt-get -y update && apt-get -y upgrade && \
#
# Add PPA for Python 3.x and R 4.0
apt -y install software-properties-common dirmngr && \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -sc)-cran40/" && \
add-apt-repository -y ppa:deadsnakes/ppa && \
#
# Install libraries
apt-get -y install \
  python3-pip \
  python3-venv \
  python-is-python3 \
  r-base && \
# Set python aliases for Python 3.x
echo 'alias python=python3' >> ~/.bashrc \
  && echo 'alias pip=pip3' >> ~/.bashrc \
  && . ~/.bashrc && \
#
#
# Install R packages
Rscript -e "install.packages('pak', repos='https://r-lib.github.io/p/pak/dev/')" && \
CORES=$(nproc) && \
export MAKEFLAGS="-j$CORES" && \
Rscript -e "pak::pkg_install(c('plotly', 'stringr', 'tm', 'dplyr', 'bib2df', 'wordcloud2', 'network', 'intergraph','igraph', 'htmlwidgets'))" && \
#
# Install sphinx and packages in a virtual environment
python -m venv .venv && \
. .venv/bin/activate && \
pip install --upgrade pip && \
pip install sphinx pydata-sphinx-theme sphinxcontrib-bibtex && \
deactivate && \
#
# Clear installation data
RUN apt-get clean

# Create a dedicated 'docker' group and user
#RUN groupadd docker && \
#  useradd -m docker -g docker -p docker && \
#  chmod 0777 /home/docker && \
#  chgrp docker /usr/local/bin && \
#  mkdir -p /home/docker/bin && chown docker /home/docker/bin
# Use this user by default
#USER docker

#ENV HOME=/home/docker
#ENV PATH="$PATH:/home/docker/bin"

#WORKDIR /home/docker
