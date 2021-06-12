#
# Multi-stage step 1: Query and generate list of Python packages specific AWS CDK version
#
FROM python:3.9-alpine
ARG CDK_VERSION=1.108.1
RUN pip install beautifulsoup4 requests
COPY list-cdk-packages.py .
RUN python list-cdk-packages.py ${CDK_VERSION} > cdk-package-list

#
# Multi-stage step 2: Build pycdk image
#
FROM alpine:3.13
ARG CDK_VERSION=1.108.1

# Set image labels
LABEL maintainer="matt@cloudmation.io mike@cumulustech.us"

# Setup
RUN mkdir /proj
WORKDIR /proj
RUN apk -U --no-cache add \
    bash \
    git \
    nodejs \
    npm \
    openssh \
    py3-cryptography \
    py3-pip &&\
    rm -rf /var/cache/apk/*

# Install additional Python tools
RUN pip install poetry

# Install CDK modules
COPY --from=0 cdk-package-list .
RUN pip install `cat cdk-package-list` > pip-install.log

# AWS CDK, AWS SDK, and Matt's CDK SSO Plugin https://www.npmjs.com/package/cdk-cross-account-plugin
RUN npm i -g aws-cdk@${CDK_VERSION} aws-sdk cdk-cross-account-plugin

# Set PYTHONPATH to support local and project specific packages
ENV PYTHONPATH="/proj/.pycdk-local:/proj"

# Set default run command
CMD ["/bin/bash"]