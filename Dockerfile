FROM rust:1.59 AS rustbase

FROM rustbase AS bandwhich
# renovate: datasource=crate depName=bandwhich
ARG BANDWHICH_VERSION=0.20.0
RUN set -x && \
    cargo install bandwhich --version "${BANDWHICH_VERSION}" && \
    /usr/local/cargo/bin/bandwhich --version

FROM rustbase AS dog
# renovate: datasource=github-releases depName=ogham/dog
ARG DOG_VERSION=v0.1.0
RUN set -x && \
    git clone -b "${DOG_VERSION}" --depth 1 https://github.com/ogham/dog.git && \
    cd dog && \
    cargo build --release && \
    ./target/release/dog --version

FROM golang:1.18 AS hey
# renovate: datasource=github-releases depName=rakyll/hey
ARG HEY_VERSION=v0.1.4
ARG TARGETOS
ARG TARGETARCH
RUN set -x && \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go install "github.com/rakyll/hey@${HEY_VERSION}"

FROM ubuntu:20.04
LABEL org.opencontainers.image.source https://github.com/superbrothers/debug
ARG TARGETARCH
RUN set -x && \
    apt update && \
    apt install -y \
        iperf \
        net-tools \
        iproute2 \
        traceroute \
        openssh-client \
        iputils-ping \
        dnsutils \
        iptables \
        tcpdump \
        nmap \
        netcat \
        iperf3 \
        less \
        tree \
        vim \
        strace \
        curl \
        bash \
        sysstat \
        iotop \
        htop \
        sysbench \
        && \
    rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"]

RUN set -x && \
    curl -L -o /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl" && \
    chmod +x /usr/local/bin/kubectl

# renovate: datasource=github-releases depName=muesli/duf
ARG DUF_VERSION=v0.8.1
RUN set -x && \
    curl -L -o duf.deb "https://github.com/muesli/duf/releases/download/${DUF_VERSION}/duf_${DUF_VERSION/v/}_linux_${TARGETARCH}.deb" && \
    dpkg -i duf.deb && \
    rm duf.deb

# renovate: datasource=github-releases depName=sharkdp/bat
ARG BAT_VERSION=v0.20.0
RUN set -x && \
    curl -L -o bat.deb "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat_${BAT_VERSION/v/}_${TARGETARCH}.deb" && \
    dpkg -i bat.deb && \
    rm bat.deb

COPY --from=hey /go/bin/hey /usr/local/bin/hey
COPY --from=bandwhich /usr/local/cargo/bin/bandwhich /usr/local/bin/bandwhich
COPY --from=dog /dog/target/release/dog /usr/local/bin/dog
