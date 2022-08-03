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
WORKDIR /data
