#!/bin/bash

if ! [ -n "$NODE_IP" ]; then
  echo NODE_IP not set
else
  flanneld \
    -iface=$NODE_IP -etcd-endpoints http://kube-control-plane:2379
fi
