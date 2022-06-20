#!/bin/bash

openssl req \
    -x509 \
    -newkey rsa:4096 \
    -nodes \
    -keyout /etc/kubernetes/service-account-key.pem \
    -out /etc/kubernetes/service-account.pem \
    -subj '/CN=localhost' \
    -sha256 \
    -days 365
