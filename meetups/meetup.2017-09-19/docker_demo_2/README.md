# Docker Demo 2

Hello World Application and Tests.

Files:
- Dockerfile: containises our application
- jenkinsfile: configures our build pipeline and is loaded by Jenkins automatically
- lib: our app code
- spec: our app's tests
- docker: directory containing scripts to build and test the application using docker

# Project Info
## Running the Build & Test phases locally

`./docker/build_and_test.sh`

---

## Dockerfile

`FROM ruby:2.3.1`

Base image, contains Ruby and Ruby related dependencies including our package manager

```
RUN apt-get update -qq \
 && apt-get install -y \
      nodejs
```
Node is required by our package manager

`WORKDIR ruby-app`

Set a working directory to store our project code inside of the container

`COPY ./ ./`

Copy our project code in to the image

---



