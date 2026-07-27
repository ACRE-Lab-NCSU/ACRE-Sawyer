#!/usr/bin/env python
import rospy
from sensor_msgs.msg import JointState

def callback(msg):
    msg.header.stamp = rospy.Time.now()
    pub.publish(msg)

rospy.init_node('joint_state_restamper')
pub = rospy.Publisher('/joint_states_corrected', JointState, queue_size=1)
sub = rospy.Subscriber('/robot/joint_states', JointState, callback)
rospy.spin()