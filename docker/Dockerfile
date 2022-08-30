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
RUN git clone https://github.com/lh3/htsbox
WORKDIR htsbox
RUN chmod +rwx *
RUN make

ENV PATH="/usr/local/bin/htsbox/:${PATH}"

WORKDIR /usr/local/bin
RUN git clone https://github.com/lh3/minimap2
WORKDIR minimap2
RUN chmod +rwx *
RUN make

ENV PATH="/usr/local/bin/minimap2/:${PATH}"

# get samtools
WORKDIR /opt/samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
    tar xvf samtools-1.9.tar.bz2 && \
    rm -r /opt/samtools/samtools-1.9.tar.bz2 && \
    cd samtools-1.9/ && \
    autoheader && \
    autoconf -Wno-header && \
    ./configure --without-curses --disable-lzma && \
    make && \
    ln -s /opt/samtools/samtools-1.9/samtools /usr/local/bin/samtools

# configure paftools.js
WORKDIR /usr/local/bin/minimap2
RUN curl -L https://github.com/attractivechaos/k8/releases/download/v0.2.4/k8-0.2.4.tar.bz2 | tar -jxf -
RUN cp k8-0.2.4/k8-`uname -s` k8
ENV PATH="${PATH}:/usr/local/bin/minimap2/:/usr/local/bin/minimap2/misc"

# install MUSCLE
WORKDIR /usr/local/bin
RUN wget https://drive5.com/muscle/downloads3.8.31/muscle3.8.31_i86linux64.tar.gz --no-check-certificate && \
  tar -xzvf muscle3.8.31_i86linux64.tar.gz && \
  rm -r muscle3.8.31_i86linux64.tar.gz && \
  mkdir muscle3.8 && \
  mv muscle3.8.31_i86linux64 muscle3.8/muscle

ENV PATH="/usr/local/bin/muscle3.8/:${PATH}"

# install prank
WORKDIR /usr/local/bin
RUN wget http://wasabiapp.org/download/prank/prank.linux64.170427.tgz && \
  tar -xzvf prank.linux64.170427.tgz && \
  rm -r prank.linux64.170427.tgz

ENV PATH="/usr/local/bin/prank/bin:${PATH}"

WORKDIR /data
