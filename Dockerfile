#
# Multi-stage step 1: Query and generate list of Python packages specific AWS CDK version
#
FROM python:3.9-alpine
ARG CDK_VERSION=1.118.0
RUN pip install beautifulsoup4 requests
COPY list-cdk-packages.py .
RUN python list-cdk-packages.py ${CDK_VERSION} > cdk-requirements.txt

#
# Multi-stage step 2: Build pycdk image
#
FROM ubuntu:hirsute
ARG CDK_VERSION=1.118.0

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

# Install Python CDK modules
COPY --from=0 cdk-requirements.txt .
RUN pip3 install -r cdk-requirements.txt > pip-install.log

# AWS CDK, AWS SDK, and Matt's CDK SSO Plugin https://www.npmjs.com/package/cdk-cross-account-plugin
RUN npm i -g aws-cdk@${CDK_VERSION} aws-sdk cdk-cross-account-plugin

# Install Python libraries and tools: Bump2Version, Invoke, Poetry
RUN pip3 install boto3 bumpver==2021.1113 invoke==1.6.0 poetry==1.1.7

#
# Install additional tools after here to avoid re-downloading CDK Python packages over and over
#

# Install Docker Client (not daemon) (https://docs.docker.com/engine/install/binaries/)
RUN curl -L -o docker.tgz https://download.docker.com/linux/static/stable/x86_64/docker-20.10.7.tgz &&\
    tar xf docker.tgz &&\
    mv docker/docker /usr/local/bin/ &&\
    rm -Rf docker docker.tgz

# Install latest AWS CLI v2
RUN curl -o awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip &&\
    unzip awscliv2.zip &&\
    ./aws/install &&\
    rm -Rf awscliv2.zip ./aws

# Set default run command
CMD ["/bin/bash"]