#!/bin/bash
IMAGE=$1
CONTAINER=$2
WS="${3:-"ros_ws"}"

# The directory from which script has been run
SIM_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
echo "Path to ${WS} volume folder: ${SIM_ROOT}/${WS}"

# TODO: делать xhost -local:docker после удаления контейнера
xhost +local:docker && \
  docker run \
    -it \
    --rm \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/.Xauthority:/root/.Xauthority \
    -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$WAYLAND_DISPLAY \
    -v /etc/localtime:/etc/localtime:ro \
    -v ${SIM_ROOT}/${WS}:/${WS} \
    -v ${SIM_ROOT}/Datasets:/Datasets \
    -v ${SIM_ROOT}/onnxruntime:/onnxruntime \
    -v ${SIM_ROOT}/openvino_toolkit:/openvino_toolkit \
    -v ${SIM_ROOT}/libtorch:/libtorch \
    -v /dev:/dev \
    --ipc=host \
    --network=host \
    --device-cgroup-rule='c *:* rmw' \
    --name ${CONTAINER} $IMAGE
    # -v ${SIM_ROOT}/ORB_SLAM3:/ORB_SLAM3 \
    # -v ${SIM_ROOT}/yolo-inference:/yolo-inference \

# Explanation of arguments:
  # xhost +local:docker - allows the Docker container to access the X11 or Wayland graphical server
  # -v /etc/localtime:/etc/localtime:ro - time settings
  # -v /tmp/.X11-unix:/tmp/.X11-unix - mounts the X11 socket
  # -v ~/.Xauthority:/root/.Xauthority - maps the .Xauthority file to the container
  # -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$WAYLAND_DISPLAY - mounts the Wayland socket
  # -e DISPLAY=$DISPLAY - sets the DISPLAY environment variable to the host's display

  # -e QT_DEBUG_PLUGINS=1 - setting this environment variable enables the output of debugging information, aiding in the troubleshooting process
  # -e QT_X11_NO_MITSHM=1 - don't remember, maybe fix for some bug