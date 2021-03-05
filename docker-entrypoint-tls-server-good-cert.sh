#!/bin/sh
# Bring up TLS server
openssl s_server -accept 12345 -cert certs/leaf_good.crt -key certs/leaf_good.key -CAfile certs/root_intermediate.crt -status_verbose -www -state
