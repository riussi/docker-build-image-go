# BASE IMAGE
FROM golang:1.20.6-bookworm

########################################
# METADATA
LABEL author="Juha Ristolainen <juha.ristolainen@iki.fi>"
LABEL org.opencontainers.image.vendor="Juha Ristolainen"
LABEL org.opencontainers.image.source="https://github.com/riussi/docker-build-image-go"
LABEL org.opencontainers.image.description="My personal Go builder-image"
LABEL org.opencontainers.image.licenses="Apache 2.0"

########################################
# ARGUMENTS
ARG USER=dev

########################################
# ENVIRONMENT
ENV DEBIAN_FRONTEND "noninteractive"
ENV HOME /home/${USER}
ENV GOLANGCILINT_VERSION 1.53.3
ENV GORELEASER_VERSION 1.19.2
ENV CGO_ENABLED 0

########################################
# SETUP THE BUILD ENV
RUN apt-get update \
    && apt-get install -y apt-utils sudo \
    && apt-get install unattended-upgrades -y \
    && apt-get upgrade -y

# Add the given user and it to sudo-group
RUN useradd -d /home/dev -s /bin/bash ${USER} -G sudo \
    && echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers
# Use the given user
USER ${USER}

########################################
# INSTALL TOOLS

# Install goreleaser
# 
RUN wget -nv https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_${GORELEASER_VERSION}_amd64.deb \
    && sudo dpkg -i goreleaser_${GORELEASER_VERSION}_amd64.deb \
    && rm -f goreleaser_${GORELEASER_VERSION}_amd64.deb

# Install golangci-lint
# https://github.com/golangci/golangci-lint/releases/download/v1.53.3/golangci-lint-1.53.3-linux-386.deb
RUN wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sudo sh -s v${GOLANGCILINT_VERSION} \
    && rm -f install.sh

WORKDIR /home/dev