# Define helper function building new images
function build-image {
    IMAGE_REPOSITORY=ghcr.io/cloudmation-llc/docker-pycdk/pycdk
    CDK_VERSION="$1"
    IMAGE_TAG="${IMAGE_REPOSITORY}:${CDK_VERSION}"
    echo "Building docker-pycdk image $IMAGE_TAG"
    docker build --build-arg BUILDKIT_INLINE_CACHE=1 --build-arg CDK_VERSION=${CDK_VERSION} -t ${IMAGE_TAG} .
}