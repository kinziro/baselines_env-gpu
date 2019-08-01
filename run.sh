docker run --runtime=nvidia --rm --name baselines-gpu-container -it \
								-e DISPLAY=$DISPLAY \
								-v 'localdir':/home/developer/workspace \
								-v /tmp/.X11-unix/:/tmp/.X11-unix \
								baselines-env-gpu \
								bash

