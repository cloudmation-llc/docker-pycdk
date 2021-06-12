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
FROM amazonlinux:2
ARG CDK_VERSION=1.108.1

# Set image labels
LABEL maintainer="matt@cloudmation.io mike@cumulustech.us"

# Install OS packages
RUN curl -fsSL https://rpm.nodesource.com/setup_16.x | bash - &&\
    amazon-linux-extras enable python3.8 &&\
    yum -y install git nodejs openssh python38 tar which unzip zip &&\
    pip3.8 install pip --upgrade &&\
    alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 &&\
    alternatives --install /usr/bin/pip3 pip3 /usr/local/bin/pip3 1 &&\
    yum clean all &&\
    git clone git://github.com/inishchith/autoenv.git $HOME/.autoenv &&\
    echo 'source $HOME/.autoenv/activate.sh' > $HOME/.bashrc

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