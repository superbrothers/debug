FROM curlimages/curl:8.8.0 AS curlbase
WORKDIR /home/curl_user

FROM curlbase AS gping
# renovate: datasource=github-releases depName=orf/gping
ARG GPING_VERSION=gping-v1.3.1
RUN set -x && \
    curl -sL https://github.com/orf/gping/releases/download/${GPING_VERSION}/gping-$(uname -m)-unknown-linux-musl.tar.gz | tar xz gping && \
    ./gping --version

FROM curlbase AS starship
# renovate: datasource=github-releases depName=starship/starship
ARG STARSHIP_VERSION=v1.19.0
RUN set -x && \
    curl -sL https://github.com/starship/starship/releases/download/${STARSHIP_VERSION}/starship-$(uname -m)-unknown-linux-musl.tar.gz | tar xz starship && \
    ./starship --version

FROM curlbase AS kubectl
ARG TARGETARCH
# renovate: datasource=github-releases depName=kubernetes/kubernetes
ARG KUBECTL_VERSION=v1.30.1
RUN set -x && \
    curl -sLO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" && \
    chmod +x kubectl && \
    ./kubectl version --client

FROM curlbase AS etcdctl
ARG TARGETARCH
# renovate: datasource=github-releases depName=etcd-io/etcd
ARG ETCD_VERSION=v3.5.14
RUN set -x && \
    curl -sL "https://storage.googleapis.com/etcd/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-${TARGETARCH}.tar.gz" | \
      tar xvzf - "etcd-${ETCD_VERSION}-linux-${TARGETARCH}/etcdctl" --strip-components=1 && \
    chmod +x etcdctl && \
    ./etcdctl version

FROM golang:1.22 AS hey
# renovate: datasource=github-releases depName=rakyll/hey
ARG HEY_VERSION=v0.1.4
ARG TARGETOS
ARG TARGETARCH
RUN set -x && \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go install "github.com/rakyll/hey@${HEY_VERSION}"

FROM curlbase AS kustomize
ARG TARGETARCH
# renovate: datasource=github-releases depName=kubernetes-sigs/kustomize versioning=regex:^kustomize\/v(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)$
ARG KUSTOMIZE_VERSION=v5.1.1
RUN set -x && \
    curl -sL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.1.1/kustomize_${KUSTOMIZE_VERSION}_linux_${TARGETARCH}.tar.gz" | tar xzf - && \
    ./kustomize version

FROM curlbase AS helm
ARG TARGETARCH
# renovate: datasource=github-releases depName=helm/helm
ARG HELM_VERSION=v3.15.2
RUN set -x && \
    curl -sL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" | tar xzf - --strip-components 1 "linux-${TARGETARCH}/helm" && \
    ./helm version

FROM ghcr.io/stern/stern:1.30.0 AS stern

FROM curlbase AS k9s
ARG TARGETARCH
# renovate: datasource=github-releases depName=derailed/k9s
ARG K9S_VERSION=v0.32.4
RUN set -x && \
    curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${TARGETARCH}.tar.gz" | tar xzf - && \
    ./k9s version

FROM docker.io/library/docker:26-cli AS docker-cli

FROM curlbase AS nerdctl
ARG TARGETARCH
# renovate: datasource=github-releases depName=containerd/nerdctl
ARG NERDCTL_VERSION=v1.7.6
RUN set -x && \
    curl -sL "https://github.com/containerd/nerdctl/releases/download/${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION//v}-linux-${TARGETARCH}.tar.gz" | tar xzf - && \
    ./nerdctl --version

FROM ubuntu:22.04
LABEL org.opencontainers.image.source https://github.com/superbrothers/debug
ARG TARGETARCH
RUN set -x && \
    apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        bash \
        bash-completion \
        build-essential \
        ca-certificates \
        curl \
        dhcpdump \
        dnsutils \
        fio \
        git \
        gnupg \
        htop \
        iotop \
        iperf \
        iperf3 \
        iproute2 \
        iptables \
        iputils-ping \
        jq \
        less \
        net-tools \
        netcat \
        nmap \
        nvtop \
        openssh-client \
        strace \
        stress-ng \
        sysbench \
        sysstat \
        tcpdump \
        traceroute \
        tree \
        vim \
        wget \
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
ARG BAT_VERSION=v0.24.0
RUN set -x && \
    curl -L -o bat.deb "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat_${BAT_VERSION/v/}_${TARGETARCH}.deb" && \
    dpkg -i bat.deb && \
    rm bat.deb

RUN set -x && \
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt-get install -y --no-install-recommends speedtest

COPY --from=hey /go/bin/hey /usr/local/bin/
COPY --from=gping /home/curl_user/gping /usr/local/bin/
COPY --from=starship /home/curl_user/starship /usr/local/bin/
COPY --from=kubectl /home/curl_user/kubectl /usr/local/bin/
COPY --from=etcdctl /home/curl_user/etcdctl /usr/local/bin/
COPY --from=kustomize /home/curl_user/kustomize /usr/local/bin/
COPY --from=helm /home/curl_user/helm /usr/local/bin/
COPY --from=stern /usr/local/bin/stern /usr/local/bin/
COPY --from=k9s /home/curl_user/k9s /usr/local/bin/
COPY --from=docker /usr/local/bin/docker /usr/local/bin/
COPY --from=nerdctl /home/curl_user/nerdctl /usr/local/bin/

COPY config/bashrc /root/.bashrc.local
RUN set -x && \
    echo ". /root/.bashrc.local" >>/root/.bashrc

COPY config/starship/starship.toml /root/.config/starship.toml
