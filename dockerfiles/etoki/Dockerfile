FROM condaforge/mambaforge:latest AS conda

RUN /opt/conda/bin/mamba install -y -n base -c bioconda -c conda-forge etoki

RUN conda clean -afy

ENV PATH /opt/conda/bin/:${PATH}

CMD ["/bin/bash"]