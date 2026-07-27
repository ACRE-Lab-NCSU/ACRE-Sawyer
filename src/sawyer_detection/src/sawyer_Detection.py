

import time

import ros_numpy
import rospy
from sensor_msgs.msg import Image

from ultralytics import YOLO

class Ultralytics:

    def __init__(self):
        self.det_image_pub = rospy.Publisher("/ultralytics/detection/image", Image, queue_size=5)
        self.seg_image_pub = rospy.Publisher("/ultralytics/segmentation/image", Image, queue_size=5)
        rospy.Subscriber("/io/internal_camera/head_camera/image_raw", Image, self.callback)
        
        self.detection_model = YOLO("yolo26m.pt")
        self.segmentation_model = YOLO("yolo26m-seg.pt")

    def callback(self, data):
        array = ros_numpy.numpify(data)
        if self.det_image_pub.get_num_connections():
            det_result = self.detection_model(array)
            det_annotated = det_result[0].plot(show=False)
            self.det_image_pub.publish(ros_numpy.msgify(Image, det_annotated, encoding="rgb8"))

        if self.seg_image_pub.get_num_connections():
            seg_result = self.segmentation_model(array)
            seg_annotated = seg_result[0].plot(show=False)
            self.seg_image_pub.publish(ros_numpy.msgify(Image, seg_annotated, encoding="rgb8"))
            print("Finished")

if __name__ == '__main__':
    rospy.init_node("ultralytics")
    Ultralytics()
    rospy.spin()
