#!/bin/bash

openssl req \
    -x509 \
    -newkey rsa:4096 \
    -nodes \
    -keyout service-account-key.pem \
    -out service-account.pem \
    -subj '/CN=localhost' \
    -sha256 \
    -days 1825
