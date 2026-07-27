
#!/bin/bash
xhost +local:root
docker run --add-host=deathstroke.local:169.254.9.39 --rm -it --network host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --device /dev/dri arms 