#!/bin/bash

etcd \
    --listen-client-urls http://0.0.0.0:2379 \
    --advertise-client-urls http://localhost:2379 \
    --data-dir /var/lib/etcd \
    --enable-v2
