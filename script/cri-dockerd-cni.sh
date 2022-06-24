#!/bin/bash

cri-dockerd \
    --container-runtime-endpoint unix:///var/run/cri-dockerd.sock \
    --cni-conf-dir /vagrant/config/cni \
    --network-plugin cni
