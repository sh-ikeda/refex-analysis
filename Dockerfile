FROM bioconductor/bioconductor_docker:RELEASE_3_14

RUN apt-get update \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN R -e 'BiocManager::install("edgeR")'
RUN R -e 'install.packages(c("data.table", "optparse", "svglite"))'
RUN R -e 'BiocManager::install("TCC")'

COPY . /work/refex-analysis/
WORKDIR /work/

CMD ["Rscript", "/work/refex-analysis/script/deg.r"]
