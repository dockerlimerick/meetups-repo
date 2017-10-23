# Docker Demo 1

Hello World Application and Tests.

Files:
- jenkinsfile: configures our build pipeline and is loaded by Jenkins automatically
- lib: our app code
- spec: our app's tests
- build_and_test.sh: installs dependencies and runs the tests

# Project Info
### Start Jenkins Container

```
docker run -p 8080:8080 -p 50000:50000 -v jenkins_demo_1_home:/var/jenkins_home jenkins/jenkins:lts
```
`-p 8080:8080`: maps container port 8080 to host machine's port 8080.

`jenkins_demo_1_home`: is the volume which contains our jenkins server's files.

`jenkins/jenkins:lts`: the image we want to start.

## Install CI Enviroment build dependencies

__As Root__

```
docker exec -it --user root [CONTAINER ID] /bin/bash
```

### Ruby version Manager
```
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
```
### Install Ruby
```
rvm install ruby
```

## add jenkins user to rvm group
```
usermod -a -G rvm jenkins
```

## Set rvm source for bash profile
```
source /etc/profile.d/rvm.sh
```