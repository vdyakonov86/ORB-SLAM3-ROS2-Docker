# Image taken from https://github.com/turlucode/ros-docker-gui
FROM osrf/ros:humble-desktop-full-jammy
ARG USE_CI
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y gnupg2 curl lsb-core vim wget python3-pip libpng16-16 libjpeg-turbo8 libtiff5

RUN apt-get install -y \
    # Base tools
    cmake \
    build-essential \
    git \
    unzip \
    pkg-config \
    python3-dev \
    # OpenCV dependencies
    python3-numpy \
    # Pangolin dependencies
    libgl1-mesa-dev \
    libglew-dev \
    libpython3-dev \
    libeigen3-dev \
    apt-transport-https \
    ca-certificates\
    software-properties-common

RUN apt update

# create a non-root user
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/$USERNAME/.config

# set up sudo privileges
RUN apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Build OpenCV
# RUN apt-get install -y python3-dev python3-numpy python2-dev
# RUN apt-get install -y libavcodec-dev libavformat-dev libswscale-dev
# RUN apt-get install -y libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev
# RUN apt-get install -y libgtk-3-dev

# RUN cd /tmp && git clone https://github.com/opencv/opencv.git && \
#     cd opencv && \
#     git checkout 4.4.0 && mkdir build && cd build && \
#     cmake -D CMAKE_BUILD_TYPE=Release -D BUILD_EXAMPLES=OFF  -D BUILD_DOCS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
#     make -j8 && make install && \
#     cd / && rm -rf /tmp/opencv

# Build Pangolin
# RUN cd /tmp && git clone https://github.com/stevenlovegrove/Pangolin && \
#     cd Pangolin && git checkout v0.9.1 && mkdir build && cd build && \
#     cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-std=c++14 -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
#     make -j8 && make install && \
#     cd / && rm -rf /tmp/Pangolin

# ===== YOLO 11 =====
# ultralytics install
# Set environment variables
# ENV PYTHONUNBUFFERED=1 \
#     PYTHONDONTWRITEBYTECODE=1 \
#     PIP_NO_CACHE_DIR=1 \
#     PIP_BREAK_SYSTEM_PACKAGES=1

# # Downloads to user config dir
# ADD https://github.com/ultralytics/assets/releases/download/v0.0.0/Arial.ttf \
#     https://github.com/ultralytics/assets/releases/download/v0.0.0/Arial.Unicode.ttf \
#     /root/.config/Ultralytics/

# # Install linux packages
# # g++ required to build 'tflite_support' and 'lap' packages, libusb-1.0-0 required for 'tflite_support' package
# RUN apt-get install -y --no-install-recommends \
#     htop libgl1 libglib2.0-0 libpython3-dev gnupg g++ libusb-1.0-0 

# # Create working directory
# WORKDIR /ultralytics

# # Copy contents and configure git
# COPY ultralytics .
# ADD https://github.com/ultralytics/assets/releases/download/v8.3.0/yolo11n.pt .

# # Install pip packages
# RUN pip install uv
# RUN uv pip install --system -e ".[export]" --extra-index-url https://download.pytorch.org/whl/cpu --index-strategy unsafe-first-match

# # Run exports to AutoInstall packages
# RUN yolo export model=tmp/yolo11n.pt format=edgetpu imgsz=32
# RUN yolo export model=tmp/yolo11n.pt format=ncnn imgsz=32
# # Requires Python<=3.10, bug with paddlepaddle==2.5.0 https://github.com/PaddlePaddle/X2Paddle/issues/991
# RUN uv pip install --system "paddlepaddle>=2.6.0" x2paddle

# # Remove extra build files
# RUN rm -rf tmp /root/.config/Ultralytics/persistent_cache.json

# WORKDIR /

# jupyter
# RUN pip install ipython ipykernel

# ===== ORB-SLAM3 =====
# prerequisites
RUN apt-get install -y g++

# Pangolin
RUN git clone --recursive https://github.com/stevenlovegrove/Pangolin.git 
# The master branch is a development branch. Choose a stable tag if you prefer.

# install deps
RUN git clone https://github.com/catchorg/Catch2.git \
    && cd Catch2 \
    && cmake -B build -S . -DBUILD_TESTING=OFF \
    && sudo cmake --build build/ --target install \
    && cd .. \
    && rm -rf /Catch2

COPY scripts/Pangolin_install_prerequisites_patch.sh /Pangolin/scripts
RUN sudo chmod +x /Pangolin/scripts/Pangolin_install_prerequisites_patch.sh 

RUN cd /Pangolin \
    && ./scripts/Pangolin_install_prerequisites_patch.sh recommended
    
# # configure and build
RUN cd /Pangolin \
    && cmake -B build \
    && cmake --build build

# install
RUN cd /Pangolin/build \
    && cmake .. \
    && sudo make install \
    && cd ../../ \
    && rm -rf /Pangolin

# eigen sources
RUN wget -O eigen.zip https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.zip \
    && unzip /eigen.zip \
    && cp -r /eigen-3.4.0/Eigen /usr/local/include \
    && rm /eigen.zip \
    && rm -rf /eigen-3.4.0

# OpenCV
# Deps to fix opencv error when run orb-slam3
RUN apt-get install -y libgtk2.0-dev pkg-config
# download and unpack sources
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.9.0.zip \
&& unzip opencv.zip \
&& mv opencv-4.9.0 opencv \
&& rm opencv.zip

# build
RUN mkdir -p /opencv_build \
&& cd /opencv_build \
&& cmake -DBUILD_TESTS=OFF ../opencv \
&& make -j4

# install, remove source/build files
RUN cd /opencv_build \
&& sudo make install \
&& cd ..
# && rm -rf /opencv /opencv_build

# Deps for building orb-slam3
RUN sudo apt-get update && sudo apt-get install -y libboost-dev libboost-serialization-dev

# TODO: move to the yolo section
RUN pip install numpy

# orbslam build script
RUN mkdir /scripts 
COPY scripts/build_orb_slam3.sh /scripts
RUN sudo chmod +x /scripts/build_orb_slam3.sh

COPY scripts/bashrc /home/${USERNAME}/bashrc
RUN cat /home/${USERNAME}/bashrc >> /home/${USERNAME}/.bashrc && rm /home/${USERNAME}/bashrc

# Build vscode (can be removed later for deployment)
# COPY ./container_root/shell_scripts/vscode_install.sh /root/
# RUN cd /root/ && sudo chmod +x * && ./vscode_install.sh && rm -rf vscode_install.sh

RUN apt-get update && apt-get install ros-humble-pcl-ros tmux -y
RUN apt-get install ros-humble-nav2-common x11-apps nano -y
RUN apt-get install -y gdb gdbserver ros-humble-rmw-cyclonedds-cpp

COPY ORB_SLAM3 /home/orb/ORB_SLAM3
COPY orb_slam3_ros2_wrapper /root/colcon_ws/src/orb_slam3_ros2_wrapper
COPY orb_slam3_map_generator /root/colcon_ws/src/orb_slam3_map_generator
COPY slam_msgs /root/colcon_ws/src/slam_msgs

# Build ORB-SLAM3 with its dependencies.
RUN if [ "$USE_CI" = "true" ]; then \
    . /opt/ros/humble/setup.sh && cd /home/orb/ORB_SLAM3 && mkdir -p build && ./build.sh && \
    . /opt/ros/humble/setup.sh && cd /root/colcon_ws/ && colcon build --symlink-install; \
    fi

RUN rm -rf /home/orb/ORB_SLAM3 /root/colcon_ws