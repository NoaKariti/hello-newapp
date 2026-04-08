FROM alpine:3.19

LABEL MAINTAINER="Eyal@levys.co.il"
LABEL GITHUB="https://github.com/elevy99927/"

ARG KUBECTL_VERSION=v1.34.1
ARG HELM_VERSION=v3.16.4
ARG TERRAFORM_VERSION=1.10.3
ARG TRIVY_VERSION=0.69.3
ARG YQ_VERSION=v4.44.6

RUN apk add --no-cache \
    curl \
    bash \
    python3 \
    py3-pip \
    jq \
    git \
    openssl \
    unzip \
    gcompat

# kubectl
RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# helm
RUN curl -LO "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \
    && tar -zxvf "helm-${HELM_VERSION}-linux-amd64.tar.gz" \
    && mv linux-amd64/helm /usr/local/bin/ \
    && rm -rf linux-amd64 "helm-${HELM_VERSION}-linux-amd64.tar.gz"

# terraform
RUN curl -LO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -d /usr/local/bin/ \
    && rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"



# trivy
RUN curl -LO "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
    && tar -zxvf "trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" trivy \
    && mv trivy /usr/local/bin/ \
    && rm "trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"

# bandit
RUN pip3 install --no-cache-dir --break-system-packages bandit

# yq
RUN curl -LO "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" \
    && chmod +x yq_linux_amd64 \
    && mv yq_linux_amd64 /usr/local/bin/yq

# # aws cli
# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
#     && unzip awscliv2.zip \
#     && ./aws/install \
#     && rm -rf awscliv2.zip aws

ARG VERSION=1
LABEL VERSION=${VERSION}

CMD ["/bin/bash"]
