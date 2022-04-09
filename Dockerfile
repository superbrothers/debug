FROM rust:1.60 AS rustbase
SHELL ["/bin/bash", "-c"]

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

FROM rustbase AS gping
# renovate: datasource=github-releases depName=orf/gping
ARG GPING_VERSION=gping-v1.3.1
RUN set -x && \
    cargo install gping --version "${GPING_VERSION/gping-v/}" && \
    /usr/local/cargo/bin/gping --version

FROM rustbase AS starship
# renovate: datasource=github-releases depName=starship/starship
ARG STARSHIP_VERSION=v1.5.4
RUN set -x && \
    cargo install starship --version "${STARSHIP_VERSION/v/}" && \
    /usr/local/cargo/bin/starship --version

FROM golang:1.18 AS hey
# renovate: datasource=github-releases depName=rakyll/hey
ARG HEY_VERSION=v0.1.4
ARG TARGETOS
ARG TARGETARCH
RUN set -x && \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go install "github.com/rakyll/hey@${HEY_VERSION}"

FROM busybox AS kubectl
ARG TARGETARCH
# renovate: datasource=github-releases depName=kubernetes/kubernetes
ARG KUBECTL_VERSION=v1.23.5
RUN set -x && \
    wget -O /kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" && \
    chmod +x /kubectl && \
    /kubectl version --client

FROM ubuntu:20.04
LABEL org.opencontainers.image.source https://github.com/superbrothers/debug
ARG TARGETARCH
RUN set -x && \
    apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        bash \
        build-essential \
        ca-certificates \
        curl \
        dhcpdump \
        dnsutils \
        git \
        htop \
        iotop \
        iperf \
        iperf3 \
        iproute2 \
        iptables \
        iputils-ping \
        less \
        net-tools \
        netcat \
        nmap \
        openssh-client \
        strace \
        sysbench \
        sysstat \
        tcpdump \
        traceroute \
        tree \
        vim \
        && \
    rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"]

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
COPY --from=gping /usr/local/cargo/bin/gping /usr/local/bin/gping
COPY --from=starship /usr/local/cargo/bin/starship /usr/local/bin/starship
COPY --from=kubectl /kubectl /usr/local/bin/kubectl

# settings for starship
RUN set -x && \
    echo 'eval "$(starship init bash)"' >>/root/.bashrc
COPY config/starship/starship.toml /root/.config/starship.toml
