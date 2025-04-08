FROM ubuntu:24.04

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && \
	apt-get remove -y python && \
	apt-get install -y --no-install-recommends \
		git \
		build-essential \
		r-base \
		r-base-dev \
		r-cran-rcppeigen \
		latexmk \
		texlive-latex-extra \
		libcurl4-openssl-dev \
		libfontconfig1-dev \
		libfreetype6-dev \
		libfribidi-dev \
		libgit2-dev \
		libharfbuzz-dev \
		libharfbuzz0b \
		libjpeg-dev \
		liblzma-dev \
		libopenblas-dev \
		libopenmpi-dev \
		libpng-dev \
		libssl-dev \
		libtiff5-dev \
		libv8-dev \
		libxml2-dev

# Install python3 and necessary dependencies
RUN apt-get install -y --no-install-recommends \
	python3 \
	python3-dev \
	python3-tk \
	python3-venv \
	python3-pip

# Create a virtual environment
RUN python3 -m venv /opt/venv

# Install python packages inside the virtual environment
RUN /opt/venv/bin/pip install --upgrade pip setuptools \
	&& /opt/venv/bin/pip install virtualenv abed wheel

# Ensure the virtual environment is used by default
ENV PATH="/opt/venv/bin:$PATH"

# Set up bash aliases for python and pip
RUN echo "alias python='/opt/venv/bin/python'" >> /root/.bash_aliases && \
	echo "alias pip='/opt/venv/bin/pip'" >> /root/.bash_aliases

# Set the default shell to bash
RUN mv /bin/sh /bin/sh.old && cp /bin/bash /bin/sh

# Clone the dataset repo
# RUN git clone https://github.com/alan-turing-institute/TCPD

# Build the dataset
# RUN cd TCPD && make export

# Clone the repo
RUN git clone --recurse-submodules https://github.com/sjmluo/TCPDBench

# Copy the datasets into the benchmark dir
# RUN mkdir -p /TCPDBench/datasets && cp TCPD/export/*.json /TCPDBench/datasets/
RUN mkdir -p /TCPDBench/datasets

# Docker only allows copying with relatives paths
COPY ./features /TCPDBench/datasets
COPY ./labels/Baseline_Pattern_Features_Server_117.json /TCPDBench/analysis/annotations/annotations.json

# Install Python dependencies inside the virtual environment
RUN /opt/venv/bin/pip install -r /TCPDBench/analysis/requirements.txt

# Install R dependencies
RUN Rscript -e "install.packages(c('argparse', 'exactRankTests'))"

# Set the working directory
WORKDIR TCPDBench
