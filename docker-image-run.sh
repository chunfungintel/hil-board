#!/bin/bash

docker run -it -p 8000:9999 --device /dev/ttyACM0 gar-registry.caas.intel.com/virtiot/hil:latest

