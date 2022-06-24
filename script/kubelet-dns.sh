#!/bin/bash

NODE_IP=$(ifconfig | grep 10.10 | awk '{print $2}')

kubelet \
    --config /vagrant/config/kubelet-config-dns.yaml \
    --container-runtime-endpoint unix:///var/run/cri-dockerd.sock \
    --kubeconfig /vagrant/config/kubeconfig.yaml \
    --node-ip "$NODE_IP"
