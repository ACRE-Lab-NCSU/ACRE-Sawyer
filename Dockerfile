FROM osrf/ros:noetic-desktop-full

SHELL ["/bin/bash", "-c"]

# Install ROS and dependencies 
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    dirmngr \
    vim \
    gnupg2 \
    lsb-release \
    sudo \
    python3 \
    python3-pip \
    git-core \
    python3-wstool \
    python3-vcstools \
    python3-rosdep \
  && sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
  && curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | apt-key add - \
  && apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-ros-base \    
    ros-noetic-control-msgs \
    ros-noetic-xacro \
    ros-noetic-tf2-ros \
    ros-noetic-rviz \
    ros-noetic-cv-bridge \
    ros-noetic-actionlib \
    ros-noetic-actionlib-msgs \
    ros-noetic-dynamic-reconfigure \
    ros-noetic-trajectory-msgs \
    ros-noetic-rospy-message-converter \
  && rm -rf /var/lib/apt/lists/*



ENV ROS_DISTRO=noetic


CMD ["bash"]


# Env vars for the nvidia-container-runtime.
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute
ENV QT_X11_NO_MITSHM=1

#Creates Workspace
COPY . /ros_ws
WORKDIR /ros_ws

RUN pip3 install --no-cache-dir argparse
#Intera SDK and Noetic Setup
RUN cd /ros_ws/src \
        && wstool init . \
        && git clone https://github.com/RethinkRobotics/sawyer_robot.git \
        && wstool merge sawyer_robot/sawyer_robot.rosinstall \
        && wstool update \
        && cd /ros_ws \
        && . /opt/ros/noetic/setup.sh && catkin_make