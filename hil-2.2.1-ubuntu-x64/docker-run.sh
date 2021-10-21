#!/bin/bash

docker run -it -p 8000:9999 -v $PWD:/hil-board -w=/hil-board --device /dev/ttyACM0 ubuntu:20.04 bash
