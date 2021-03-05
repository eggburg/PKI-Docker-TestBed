#!/bin/sh
# Bring up TLS server
openssl s_server -accept 54321 -cert certs/leaf_revoked.crt -key certs/leaf_revoked.key -CAfile certs/root_intermediate.crt -status_verbose -www -state
