# CDK Python Docker Image <!-- omit in toc -->

- [Introduction](#introduction)
- [Usage](#usage)
  - [VS Code Dev Containers](#vs-code-dev-containers)
  - [Standalone](#standalone)

## Introduction

`docker-pycdk` is a collaborative effort to develop an *all-in-one* toolbox for creating and maintaining AWS deployments using the AWS CDK.

A problem we are trying to solve for is how to deal with the cognitive overload of installing so many new and different tools -- especially when introducing AWS and infrastructure-as-code practices to our client teams who traditionally have never used such tools in their work. Our approach using a Docker image is to package together the following:

* Language runtimes *(in this case both Node.js and Python)*
* The CDK tooling *(installed with `npm`)*
* The CDK construct libraries for Python *(installed with `pip`)*. Both this and the tooling are pinned to a specific version at build time to keep it simple.
* AWS CLI v2
* "Daemonless" Docker image building (for advanced uses like ECR or Lambda images)
* Additional Node.js/CDK tooling such as our cross-account authentication plugin
* Additional Python tooling (i.e. Poetry)
* Pre-configured practices like extending the Python environment with locally mounted packages

There are so many things to install -- plus add in personal preferences for different operating systems -- how can you ensure it all gets installed properly for a team? And teach it in a sane way?

The end result of this project is a **portable** and **consistent** CDK development environment that works on Mac, Linux, or Windows -- or in other words anywhere you can set up operational Docker environment.

As you can see in the project name this specific project has bias to developing CDK projects using Python.

## Usage

### VS Code Dev Containers

At time of writing using containers as a dev environment with a deep IDE integration is a new area exploration. [PyCharm](https://www.jetbrains.com/pycharm/) has a good start in this direction, but it is not very customizable for unique requirements.

[VS Code](https://code.visualstudio.com) on the other hand has an outstanding implementation of [remote dev environments](https://code.visualstudio.com/docs/remote/remote-overview) using Docker containers and other protocols. The fact that you can even call out specific VS Code extensions in a portable way from person to person is on another level.

Early testing has shown thus far this is a very productive way to work on a CDK project.

**Sample `devcontainer/devcontainer.json` for VS Code**
```json
{
    "image": "docker.pkg.github.com/cloudmation-llc/docker-pycdk/pycdk:1.108.1",
    "extensions": [
        "bungcip.better-toml",
        "dlech.chmod",
        "ms-python.python",
        "sleistner.vscode-fileutils"
    ],
    "remoteEnv": {
        "AUTOENV_ASSUME_YES": "true",
        "AUTOENV_ENV_FILENAME": ".autoenv.sh",
        "PYTHONPATH": "/workspaces/Cloudmation/.pycdk-local:/workspaces/Cloudmation"
    },
    "mounts": [
        "source=${localEnv:HOME}/.aws,target=/root/.aws,type=bind,consistency=cached",
        "source=${localEnv:HOME}/.vscode-devcontainer-cache,target=/root/.cache,type=bind,consistency=cached"
    ],
    "runArgs": [
        "--privileged"
    ]
}
```

The above sample is what I have been using for testing, but you do not need to follow it precisely. For example the use of the `--privileged` flag is optional and I have it enabled because I am testing building Docker images in a docker container using the daemoneless build tool [img](https://github.com/genuinetools/img).

*The point is this: customize liberally according to your needs and/or organization.*

### Standalone

TBD

<!-- ## Setup

### Bash Profile Script

Add env bash script to .profile or .bashrc Example:

``` . ~/docker-pycdk/cdk-bash.sh```

### Docker Tag

You must tag an image as "active" in order to determine which version of the cdk to use.

```
docker pull cumulusmike/pycdk:1.86.0
docker tag cumulusmike/pycdk:1.86.0 cumulusmike/pycdk:active
```

### AWS SSO Setup

Only needed once per workstation. Follow "Automatic configuration" instructions.  Repeat for each profile.

https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html

## Usage

### Initial Login

Must be performed once per session.

```$ aws sso login --profile client-dev```

Optional Verify SSO

```$ aws sts get-caller-identity --profile client-dev```

### Example Inline CDK Commands

```
$ cdk --version
$ pycdk python --version
```

### Interactive CDK Shell

```$ pycdk```

## Cheat Sheets

### Existing repo - new clone

```
$ git clone git@github.com:client/cdk-project.git
$ cd cdk-project
$ cdk ls
$ cdk diff
```

### New Python CDK Project From Scracth

```
$ mkdir cdk-project
$ cd cdk-project
$ cdk init --language python
#remove .venv or .env
$ sudo chown mike:mike -R *
$ sudo chown mike:mike -R .*
# Create GitHub repo
$ git remote add origin git@github.com:client/cdk-project.git
$ git push --set-upstream origin master
```

## Maintenance

### Automated Image Build

1. Update Dockerfile and commit changes to master branch. A build for "latest" will automatically start in Dockerhub.
2. Create a version tag in Github and a version build/tag will automatically start in Dockerhub.
### Manual Image Build

```
$ cd docker-pycdk
$ docker build . -t cumulusmike/pycdk:1.86.0 -t cumulusmike/pycdk:latest --build-arg CDK_VERSION=1.86.0
$ docker push cumulusmike/pycdk:1.86.0
$ docker push cumulusmike/pycdk:latest
``` -->