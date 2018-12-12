# tileserver-gl-arm
Code and instructions for building an ARMv8 tileserver-gl docker image.

## Building the docker image

_NOTE: The docker image must be built on an ARMv8 board so that an ARM docker image is created._

First clone this repository. Because we are using submodules, use the `--recursive` flag, like:
```
git clone --recursive <url>
```
Then, change directories into the root of the repository and run:
```
docker build -t tileserver-gl-arm .
```
This will create the docker image.

## Running tileserver-gl-arm
To run the docker image, change into the directory containing your _.mbtiles_ file and run:
```
docker run -it --rm -v $(pwd):/data -p 8080:80 tileserver-gl-arm
```
This will start the tileserver on http://localhost:8080.
Alternatively, you can start the server from anywhere and replace `$(pwd)` with the full path to your data directory.

## Installing the docker image on other machines
If a network will be available, the image can be pushed to a repository, such as Docker Hub. See the Docker documentation for details.

For machines without a network, you can save the image as a tar file:
```
docker save -o tileserver-gl-arm.tar tileserver-gl-arm
```

The tar file then must be transferred to the other machine via USB drive, etc. On the remote machine, run:
```
docker load -i tileserver-gl-arm.tar
```
The image can then be run as above.
