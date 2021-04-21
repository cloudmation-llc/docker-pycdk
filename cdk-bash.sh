# Docker CDK environment configuration for Bash/Zsh

# Add to .profile or .bashrc Example:
#  . ~/docker-pycdk/cdk-bash.sh

function aws {
    docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli $*
}

function cdk {
    docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/proj docker.pkg.github.com/cloudmation-llc/docker-pycdk/pycdk:active cdk $*
}

function pycdk {
    # Evaluate command
    if [ "$1" = "add-packages" ]; then
        pycdk_add_packages ${@:2}
    elif [ "$1" = "version" ]; then
        pycdk_set_version $2
    else
       echo "pycdk: error: $1 is not a known command"
    fi
}

function pycdk_add_packages {
    echo "pycdk: Installing package(s) $*"
    docker run --rm -it \
        -v ~/.aws:/root/.aws \
        -v $(pwd):/proj \
        docker.pkg.github.com/cloudmation-llc/docker-pycdk/pycdk:active \
        pip install --target .pycdk-local $*
}

function pycdk_set_version {
    echo "Setting active version to $1"

    # Pull the image from the repository if it does not exist locally
    docker inspect --format='{{.Id}}' docker.pkg.github.com/cloudmation-llc/docker-pycdk/pycdk:$1
    if [ $? -eq 1 ]; then
        echo "pycdk: Fetching image for version $1"
        docker pull docker.pkg.github.com/cloudmation-llc/docker-pycdk/pycdk:$1
    fi

    # Apply the 'active' tag to the selected image
    docker tag docker.pkg.github.com/cloudmation-llc/docker-pycdk/pycdk:$1 docker.pkg.github.com/cloudmation-llc/docker-pycdk/pycdk:active
}