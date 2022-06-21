#!/bin/bash

cat << EOF | etcdctl put /coreos.com/network/config
    {
        "Network": "10.2.0.0/16",
        "Backend": {
            "Type": "vxlan"
        }
    }
EOF
