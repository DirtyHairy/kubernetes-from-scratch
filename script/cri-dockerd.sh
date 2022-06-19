#!/bin/bash

cri-dockerd \
    --container-runtime-endpoint unix:///var/run/cri-dockerd.sock
