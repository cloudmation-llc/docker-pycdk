FROM alpine:3.13

# Set image labels
LABEL maintainer="matt@cloudmation.io mike@cumulustech.us"

# Set build args with defaults
ARG CDK_VERSION=1.105.0

# Setup
RUN mkdir /proj
WORKDIR /proj
RUN apk -U --no-cache add \
    bash \
    git \
    nodejs \
    npm \
    py3-cryptography \
    py3-pip &&\
    rm -rf /var/cache/apk/*

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install essential Python packages
RUN pip install beautifulsoup4 cryptography requests poetry

# Set PYTHONPATH to support local/project specific packages
ENV PYTHONPATH="/proj/.pycdk-local:/project/.venv/lib"

# Query PyPI registry for all installable CDK modules
# (@Feb-22-2021 MR - I would like to replace this in the future with CDK monorepo -- too experimental right now)
COPY list-cdk-packages.py .
RUN CDK_PACKAGES=`./list-cdk-packages.py ${CDK_VERSION}` && pip install `echo $CDK_PACKAGES`

# AWS CDK, AWS SDK, and Matt's CDK SSO Plugin https://www.npmjs.com/package/cdk-cross-account-plugin
RUN npm i -g aws-cdk@${CDK_VERSION} aws-sdk cdk-cross-account-plugin

# Set default run command
CMD ["/bin/bash"]