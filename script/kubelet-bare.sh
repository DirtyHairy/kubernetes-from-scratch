#!/bin/bash

if ! [ -n "$NODE_IP" ]; then
    echo NODE_IP not set
else
    kubelet \
    --config /etc/kubernetes/kubelet-config.yaml \
    --container-runtime-endpoint unix:///var/run/cri-dockerd.sock \
    --node-ip "$NODE_IP"
fi
