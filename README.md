# Docker for Powershell
Use Docker on Windows without Docker-Desktop via a custom WSL-distribution based on Alpine Linux

## Installation

Download the [installer](https://github.com/soehms/docker_for_powershell/releases/download/0.1/docker_for_powershell-0.2-installer.ps1) and execute it with Powershell. If you don't have WSL installed, you are asked to install it. This will need a reboot of your computer. In this case restart the installer afterwards.

To check if the installation has been successful type `wsl -l -q` in a powershell terminal.  You should see the `WSL` distribution of `DockerForPowershell` there:

```
PS C:\Users\sebastian> wsl -l -q
...
DockerForPowershell-0.2
...
```


## Usage

Start the Docker daemon by (replacing the version number if necessary):

```
wsl -d DockerForPowershell-0.2 -e sh /root/start_dockerd
```

Use Docker by

```
wsl -d DockerForPowershell-0.2 -e docker <arguments>
```

To have it more comfortable you may define these two functions:

```
function docker {return wsl -d DockerForPowershell-0.2 -e docker $args}
function start_docker_daemon {return wsl -d DockerForPowershell-0.2 -e sh /root/start_dockerd}
```

Using them you shoud see an output like this:

```
PS C:\Users\sebastian> start_docker_daemon
PS C:\Users\sebastian> docker info
Client:
 Version:    26.1.5
 Context:    default
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.14.0
    Path:     /usr/libexec/docker/cli-plugins/docker-buildx

Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
 Server Version: 26.1.5
 Storage Driver: overlay2
....

PS C:\Users\sebastian> docker images
REPOSITORY   TAG       IMAGE ID   CREATED   SIZE
```
