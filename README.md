# ACRE-Sawyer
Hello, welcome to the ACRE Sawyer page!
## Configuring the Network Card and Sawyer
### Network Card
### Sawyer
After doing a factory reset, the Sawyer will need to be reconfigured to work properly. The networking guide provided by Rethink Robotics can be found [here](https://web.archive.org/web/20230128035456/https://sdk.rethinkrobotics.com/intera/Networking). To connect, the robot must be in SDK mode, which is done in the [field service menu](https://web.archive.org/web/20230217224419/https://sdk.rethinkrobotics.com/intera/Field_Service_Menu_(FSM)). There are 2 ways of connecting the Sawyer with a computer, which is done by either connecting both the robot and computer into a router or by connecting the computer and robot directly to one another. The different methods will use different IP address templates, with the router method using 196.168.xxx.yyy while the direct connection method uses 169.254.xxx.yyy. The robot can be set to use either an IP address or hostname, with the computer using the opposite. The dockerfile assumes that the robot is being directly connected with the computer and that the robot is using a hostname rather than the computer. After running the dockerfile, the intera.sh script must be modified, with the spaces after the IP address and hostname needing to be deleted. This is because the intera.sh script won't run unless it recognizes that an user has edited the IP and hostname.
#### Issues
Issue: Robot hostname is not recognized.

Solution: When running the dockerfile, check the run.sh file to see that the IP address is set up properly. The argument should be changed accord to the name and IP address of the robot.

```
--add-host=deathstroke.local:169.254.9.39 --rm
```


Issue: The robot is recognized and can be pinged, but does not publish data to nodes.

Solution: Change the IP configuration from automatic to static and set all of the parameters. This is done through the field service menu.
## Using the Robot
Before trying to run any code on the Sawyer, be sure to set the robot into SDK mode through the Field Service Menu. This will allow ROS to communicate with the robot. Ensure the IP addresses and hostnames are correct to ensure that the robot and computer are connected together. Once everything has been checked, run the command 

```
./run.sh
```

After starting the docker, edit the intera.sh program. This code utilizes Vim to do this, but can be modified to the user's preference. Remove the spaces after the robot hostname and the IP of the computer. This is done as the program checks to see if the two have been edited before allowing the code to be ran. After this, run 

```
./intera.sh
```

You can now run code on your Sawyer! Examples by Rethink Robotics can be found [here](https://web.archive.org/web/20230128035525/https://sdk.rethinkrobotics.com/intera/Running_Examples_Overview).
### Utilizing YOLO and MoveIt!
The official MoveIt! guide can be found [here](https://web.archive.org/web/20230128035522/https://sdk.rethinkrobotics.com/intera/MoveIt_Tutorial). After running ./intera.sh. activate the robot with the command rosrun intera_interface enable_robot.py -e. Then start the joint trajectory controller with the command rosrun intera_interface joint_trajectory_action_server.py & and press enter. To start MoveIt!, run either roslaunch sawyer_moveit_config sawyer_moveit.launch if the gripper is not attached or roslaunch sawyer_moveit_config sawyer_moveit.launch electric_gripper:=true if the gripper is attached. Now you can start using MoveIt!

To utilize YOLO, activate the robot with the command

```
rosrun intera_interface enable_robot.py -e
```

Afterwards, run 

```
rosrun sawyer_detection sawyer_Detection.py &
```

The output of the program can be viewed in Rviz with under the images of detection and segmentation of ultralytics.
#### Issues
Issue: YOLO doesn't output any images

Solution: After rebooting or starting Sawyer, the cameras do not activate automatically. Running the [camera image example](https://web.archive.org/web/20230128035209/https://sdk.rethinkrobotics.com/intera/Camera_Image_Display_Example) and closing out of it will activate them and allow YOLO to function normally until the robot is rebooted or shut down. The command to run the camera image example is 

```shell
rosrun intera_examples camera_display.py
```

## Using the Sim
Currently, the sim is not functioning due to issues caused by the code to download the sim. The Rethink Robotics guide can be found [here](https://web.archive.org/web/20230128035524/https://sdk.rethinkrobotics.com/intera/Gazebo_Tutorial).

#### Issues
Issue: Unable to communicate with master! 

Solution: Run roscore & after running 

```
./intera.sh sim
```
