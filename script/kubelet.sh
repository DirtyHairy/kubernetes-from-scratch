#!/bin/bash

NODE_IP=$(ifconfig | grep 10.10 | awk '{print $2}')

kubelet \
    --config /etc/kubernetes/kubelet-config.yaml \
    --container-runtime-endpoint unix:///var/run/cri-dockerd.sock \
    --kubeconfig /etc/kubernetes/kubeconfig.yaml \
    --node-ip "$NODE_IP"
