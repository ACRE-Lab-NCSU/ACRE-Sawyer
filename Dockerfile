FROM osrf/ros:noetic-desktop-full

SHELL ["/bin/bash", "-c"]

# Install ROS, Gazebo and dependencies 
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    dirmngr \
    vim \
    gnupg2 \
    lsb-release \
    sudo \
    python3 \
    iputils-ping \
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
    gazebo11 \
    ros-noetic-gazebo-ros  \
    ros-noetic-gazebo-ros-control \
    ros-noetic-gazebo-ros-pkgs \
    ros-noetic-ros-control \
    ros-noetic-control-toolbox \
    ros-noetic-realtime-tools \ 
    ros-noetic-ros-controllers \
    ros-noetic-tf-conversions \
    ros-noetic-kdl-parser \
    ros-noetic-moveit \
    ros-noetic-catkin \
    python3-catkin-tools \
    python3-osrf-pycommon \
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

#Installs YOLO 
RUN pip install rosnumpy 
RUN pip install ultralytics

#Intera SDK, Noetic, and  Setup
RUN cd /ros_ws/src \
        && wstool init . \
        && git clone https://github.com/RethinkRobotics/sawyer_robot.git \
        && git clone https://github.com/RethinkRobotics-opensource/sns_ik.git -b melodic-devel \
        #&& git clone https://github.com/RethinkRobotics/sawyer_simulator.git -b noetic_devel \
        && wstool merge sawyer_robot/sawyer_robot.rosinstall \
        #&& wstool merge sawyer_simulator/sawyer_simulator.rosinstall \
        && wstool merge https://raw.githubusercontent.com/RethinkRobotics/sawyer_moveit/melodic_devel/sawyer_moveit.rosinstall \
        && wstool update \
        && cd /ros_ws \
        && . /opt/ros/noetic/setup.sh && catkin_make

  
RUN mv /ros_ws/src/intera_sdk/intera.sh /ros_ws/

RUN sed -i "s|kinetic|noetic|g" /ros_ws/intera.sh

#Replace 169.254.9.10 with the IP of the network card used to connect the robot to the computer
RUN sed -i "s|192.168.XXX.XXX|169.254.9.10 |g" /ros_ws/intera.sh

#Deathstroke should be replaced with the hostname of the robot, which can be changed in the FSM Menu
RUN sed -i "s|robot_hostname.local|deathstroke.local |g" /ros_ws/intera.sh

#After booting, delete the spaces after the IP Address and Hostname

#Edits for YOLOs
RUN sed -i "s|# catkin_install_python(PROGRAMS| catkin_install_python(PROGRAMS|g" /ros_ws/src/sawyer_detection/CMakeLists.txt 
RUN sed -i "s|#   scripts/my_python_script|   src/sawyer_Detection.py src/joint_state_corrected.py |g" /ros_ws/src/sawyer_detection/CMakeLists.txt 
RUN sed -i "163s|#   DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}|   DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}|g" /ros_ws/src/sawyer_detection/CMakeLists.txt 
RUN sed -i "164s|# )| )|g" /ros_ws/src/sawyer_detection/CMakeLists.txt 
RUN . /opt/ros/noetic/setup.sh && catkin_make

# To use YOLO, activate the robot with the command rosrun intera_interface enable_robot.py -e