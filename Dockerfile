#
# Multi-stage step 1: Query and generate list of Python packages specific AWS CDK version
#
FROM python:3.9-alpine
ARG CDK_VERSION=1.108.1
RUN pip install beautifulsoup4 requests
COPY list-cdk-packages.py .
RUN python list-cdk-packages.py ${CDK_VERSION} > cdk-requirements.txt

#
# Multi-stage step 2: Build pycdk image
#
FROM ubuntu:focal
ARG CDK_VERSION=1.108.1

# Set image labels
LABEL maintainer="matt@cloudmation.io mike@cumulustech.us"

# Install OS packages (Ubuntu)
RUN apt-get update && apt-get install -y curl &&\
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends git openssh-client nodejs python3 python3-pip unzip zip &&\
    rm -rf /var/lib/apt/lists/* &&\
    git clone git://github.com/inishchith/autoenv.git $HOME/.autoenv &&\
    echo 'source $HOME/.autoenv/activate.sh' > $HOME/.bashrc

# Install img (https://github.com/genuinetools/img)
RUN curl -L -o /usr/local/bin/img https://github.com/genuinetools/img/releases/download/v0.5.11/img-linux-amd64 &&\
    chmod +x /usr/local/bin/img

# Install latest AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&\
    unzip awscliv2.zip &&\
    ./aws/install &&\
    rm -Rf awscliv2.zip ./aws

# Install additional Python tools
RUN pip3 install poetry

# Install CDK modules
COPY --from=0 cdk-requirements.txt .
RUN pip3 install -r cdk-requirements.txt > pip-install.log

# AWS CDK, AWS SDK, and Matt's CDK SSO Plugin https://www.npmjs.com/package/cdk-cross-account-plugin
RUN npm i -g aws-cdk@${CDK_VERSION} aws-sdk cdk-cross-account-plugin

# Set PYTHONPATH to support local and project specific packages
ENV PYTHONPATH="/proj/.pycdk-local:/proj"

# Set default run command
CMD ["/bin/bash"]