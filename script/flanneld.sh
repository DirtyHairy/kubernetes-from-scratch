#!/bin/bash

NODE_IP=$(ifconfig | grep 10.10 | awk '{print $2}')

flanneld \
    -iface=$NODE_IP -etcd-endpoints http://kube-control-plane:2379
