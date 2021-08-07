# CDK Python Docker Image <!-- omit in toc -->

- [Introduction](#introduction)
- [Usage](#usage)
  - [VS Code Dev Containers](#vs-code-dev-containers)

## Introduction

`docker-pycdk` is an effort to develop an *all-in-one* toolbox for creating and maintaining AWS deployments using the AWS CDK and Python.

A problem we are trying to solve for is how to deal with the cognitive overload of installing so many new and different tools -- especially when introducing AWS and infrastructure-as-code practices to our client teams who traditionally have never used such tools in their work. Our approach using a Docker image is to package together the following:

* Language runtimes *(in this case both Node.js and Python)*
* The CDK tooling *(installed with `npm`)*
* The CDK construct libraries for Python *(installed with `pip`)*. Both this and the tooling are pinned to a specific version at build time to keep it simple.
* AWS CLI v2
* Docker client (for advanced uses like ECR or Lambda images)
* Additional Node.js/CDK tooling such as our cross-account authentication plugin
* Additional Python tooling (i.e. Poetry)
* Pre-configured practices like extending the Python environment with locally mounted packages

There are so many things to install -- plus add in personal preferences for different operating systems -- how can you ensure it all gets installed properly for a team? And teach it in a sane way?

The end result of this project is a **portable** and **consistent** CDK development environment that works on Mac, Linux, or Windows -- or in other words anywhere you can set up an operational Docker environment.

## Usage

### VS Code Dev Containers

At time of writing using containers as a dev environment with a deep IDE integration is a new area exploration. [PyCharm](https://www.jetbrains.com/pycharm/) has a good start in this direction, but it is not very customizable for unique requirements.

[VS Code](https://code.visualstudio.com) on the other hand has an outstanding implementation of [remote dev environments](https://code.visualstudio.com/docs/remote/remote-overview) using Docker containers and other protocols. The fact that you can even call out specific VS Code extensions in a portable way from person to person is on another level.

Early testing has shown thus far this is a very productive way to work on a CDK project.

**Sample `devcontainer/devcontainer.json` for VS Code**
```json
{
    "image": "ghcr.io/cloudmation-llc/docker-pycdk/pycdk:1.117.0",
    "extensions": [
        "bungcip.better-toml",
        "dlech.chmod",
        "ms-python.python",
        "sleistner.vscode-fileutils"
    ],
    "remoteEnv": {
        "AUTOENV_ASSUME_YES": "true",
        "AUTOENV_ENV_FILENAME": ".autoenv.sh",
        "PYTHONPATH": "/workspaces/yourproject/.pycdk-local:/workspaces/yourproject",
        "TZ": "America/Los_Angeles"
    },
    "mounts": [
        "source=${localEnv:HOME}/.aws,target=/root/.aws,type=bind,consistency=cached",
        "source=${localEnv:HOME}/.vscode-devcontainer-cache,target=/root/.cache,type=bind,consistency=cached"
    ]
}
```

The above sample is what I have been using for testing, but you do not need to follow it precisely. *Customize liberally according to your needs and/or organization.*