FROM rocker/rstudio:latest

MAINTAINER Tim Stuart <stuartt@gis.a-star.edu.sg>

ARG bioc_ver=3.18

RUN apt-get clean all && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y \
		libhdf5-dev \
		libcurl4-gnutls-dev \
		libssl-dev \
		libxml2-dev \
		libpng-dev \
		libxt-dev \
		zlib1g-dev \
		libbz2-dev \
		liblzma-dev \
		libglpk40 \
		libgit2-dev \
	&& apt-get clean all && \
	apt-get purge

RUN Rscript -e "install.packages(c('rmarkdown', 'tidyverse', 'devtools', 'BiocManager'));"
RUN Rscript -e "BiocManager::install(version = '${bioc_ver}')"
RUN Rscript -e "setRepositories(ind=1:3); install.packages(c('Seurat', 'Signac'), dependencies=TRUE)"

WORKDIR /home/rstudio
