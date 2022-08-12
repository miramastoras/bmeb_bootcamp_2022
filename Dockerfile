FROM ubuntu:18.04
MAINTAINER Mira Mastoras mmastora@ucsc.edu

ARG git_commit

# to make it easier to upgrade for new versions; ARG variables only persist during docker image build time
ARG SPAdesVer=3.15.4

# install dependencies; cleanup apt garbage
# python v3.8.10 is installed here; point 'python' to python3
RUN apt-get update && apt-get install --no-install-recommends -y python3 \
 python3-distutils \
 wget && \
 apt-get autoclean && rm -rf /var/lib/apt/lists/* && \
 update-alternatives --install /usr/bin/python python /usr/bin/python3 10

# install SPAdes binary; make /data
WORKDIR /usr/local/bin
RUN wget http://cab.spbu.ru/files/release${SPAdesVer}/SPAdes-${SPAdesVer}-Linux.tar.gz && \
  tar -xzf SPAdes-${SPAdesVer}-Linux.tar.gz && \
  rm -r SPAdes-${SPAdesVer}-Linux.tar.gz

# add spades to path
ENV PATH="/usr/local/bin/SPAdes-${SPAdesVer}-Linux/bin/:${PATH}"

# install minimap2

WORKDIR /usr/local/bin
# install deps and cleanup apt garbage
RUN apt-get update && apt-get install -y python \
 curl git \
 bzip2 && \
 apt-get autoclean && rm -rf /var/lib/apt/lists/*

# update and install dependencies
RUN apt-get update && \
    apt-get -y install time git make wget autoconf gcc g++ zlib1g-dev libcurl4-openssl-dev libbz2-dev libhdf5-dev liblzma-dev && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update \
  && apt-get install -y python3-pip python3-dev jq pigz \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 --no-cache-dir install --upgrade pip \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/bin
RUN git clone https://github.com/lh3/htsbox \
    cd htsbox \
    make

ENV PATH="/usr/local/bin/htsbox/:${PATH}"

WORKDIR /usr/local/bin
RUN git clone https://github.com/lh3/minimap2 \
    cd minimap2 \
    make

ENV PATH="/usr/local/bin/minimap2/:${PATH}"

WORKDIR /data
