# Define helper function building new images
function build-image {
    # Validate a CDK version string is provided
    [[ -z "$1" ]] && echo "Error: CDK version string is required" && return 1

    # Configure variables
    IMAGE_REPOSITORY=ghcr.io/cloudmation-llc/docker-pycdk/pycdk
    CDK_VERSION="$1"
    IMAGE_TAG="${IMAGE_REPOSITORY}:${CDK_VERSION}"

    # Build and push image
    echo "Building docker-pycdk image $IMAGE_TAG"
    docker build --build-arg BUILDKIT_INLINE_CACHE=1 --build-arg CDK_VERSION=${CDK_VERSION} -t ${IMAGE_TAG} . &&\
        docker push ${IMAGE_TAG}
}