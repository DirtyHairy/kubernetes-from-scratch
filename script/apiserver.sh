#!/bin/bash

kube-apiserver \
  --allow-privileged=true \
  --etcd-servers=http://localhost:2379 \
  --service-cluster-ip-range=10.1.0.0/16 \
  --bind-address=0.0.0.0 \
  --authorization-mode=AlwaysAllow \
  --disable-admission-plugins=ServiceAccount \
  --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname \
  --token-auth-file /etc/kubernetes/token.txt \
  --service-account-key-file /etc/kubernetes/service-account.pem \
  --service-account-signing-key-file /etc/kubernetes/service-account-key.pem \
  --service-account-issuer api
