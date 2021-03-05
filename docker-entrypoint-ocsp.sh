#!/bin/sh
# Bring up OCSP responder
openssl ocsp -index certs/index.txt -port 8888 -rsigner certs/ocsp_responder.crt -rkey certs/ocsp_responder.key -CA certs/intermediate.crt -text
