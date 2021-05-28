# Docker CDK environment configuration for Bash/Zsh

# Add to .profile or .bashrc Example:
#  . ~/docker-pycdk/cdk-bash.sh

PYCDK_IMAGE_PREFIX=docker.pkg.github.com/cloudmation-llc/docker-pycdk/pycdk

function aws {
    # Build initial Docker command
    DOCKER_CMD=(run --rm -v ~/.aws:/root/.aws -v $(pwd):/aws)

    # If AWS_ACCESS_KEY_ID is set, pass into container
    if [ -n "${AWS_ACCESS_KEY_ID}" ]; then
        DOCKER_CMD+=(-e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID)
    fi

    # If AWS_SECRET_ACCESS_KEY is set, pass into container
    if [ -n "${AWS_SECRET_ACCESS_KEY}" ]; then
        DOCKER_CMD+=(-e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY)
    fi

    # If AWS_SESSION_TOKEN is set, pass into container
    if [ -n "${AWS_SESSION_TOKEN}" ]; then
        DOCKER_CMD+=(-e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN)
    fi

    # Finish assembling AWS command
    DOCKER_CMD+=(amazon/aws-cli $*)

    # Run container instance
    docker ${DOCKER_CMD[@]}
}

function cdk {
    # Build initial Docker command
    DOCKER_CMD=(run --rm -v ~/.aws:/root/.aws -v $(pwd):/proj -e TERM=xterm-256color)

    # Check for and additional extra args provided at runtime
    if [ -n "${DOCKER_PYCDK_EXTRA_ARGS}" ]; then
        DOCKER_CMD+=($(eval echo $DOCKER_PYCDK_EXTRA_ARGS))
    fi

    # Finish assembling CDK command
    DOCKER_CMD+=(${PYCDK_IMAGE_PREFIX}:active cdk $*)

    # Run container instance
    docker ${DOCKER_CMD[@]}
}

function pycdk {
    # Evaluate command
    if [ "$1" = "add-packages" ]; then
        pycdk_add_packages ${@:2}
    elif [ "$1" = "set-cdk-version" ] || [ "$1" = "active" ]; then
        pycdk_set_version $2
    else
       echo "pycdk: error: \"$1\" is not a known command"
    fi
}

function pycdk_add_packages {
    echo "pycdk: Installing package(s) $*"

    # Build initial Docker command
    DOCKER_CMD=(run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/proj -e TERM=xterm-256color)

    # Check for and additional extra args provided at runtime
    if [ -n "${DOCKER_PYCDK_EXTRA_ARGS}" ]; then
        DOCKER_CMD+=($(eval echo $DOCKER_PYCDK_EXTRA_ARGS))
    fi

    # Finish assembling pip command
    DOCKER_CMD+=(${PYCDK_IMAGE_PREFIX}:active pip install --target /proj/.pycdk-local $*)

    # Run container instance
    docker ${DOCKER_CMD[@]}
}

function pycdk_set_version {
    echo "Setting active version to $1"

    # Pull the image from the repository if it does not exist locally
    docker inspect --format='{{.Id}}' ${PYCDK_IMAGE_PREFIX}:$1
    if [ $? -eq 1 ]; then
        echo "pycdk: Fetching image for version $1"
        docker pull ${PYCDK_IMAGE_PREFIX}:$1
    fi

    # Apply the 'active' tag to the selected image
    docker tag ${PYCDK_IMAGE_PREFIX}:$1 ${PYCDK_IMAGE_PREFIX}:active
}