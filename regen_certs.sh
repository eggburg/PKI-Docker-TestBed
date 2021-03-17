#!/bin/sh
cd certs/

echo "Clean up existing key/csr/cert/pem/der"
eval `rm -rf *.key *.csr *.crt *.pem *.der`

echo "====================================================="
echo "Generating root key/cert"
eval `openssl req -x509 -keyout root.key -out root.crt -days 3650 -nodes \
		-subj '/C=US/L=San Jose/CN=root_cn'`

echo "====================================================="
echo "Generating intermediate key/csr/cert"
eval `openssl req -new -nodes -addext basicConstraints=CA:TRUE \
		-keyout intermediate.key -out intermediate.csr \
		-subj '/C=US/L=San Jose/CN=intermediate_cn' && openssl x509 -req \
		-days 3650 -in intermediate.csr -CA root.crt -CAkey root.key \
		-set_serial 0x11111111 -out intermediate.crt -extfile extfile_for_ca_cert`

echo "====================================================="
echo "Generate root intermediate CA chain"
eval `cat root.crt intermediate.crt > root_intermediate.crt`

echo "====================================================="
echo "Generate revoked status leaf key/csr/cert"
eval `openssl req -new -nodes -out leaf_revoked.csr -keyout leaf_revoked.key \
		-subj '/C=US/L=San Jose/CN=leaf_revoked_cn' && openssl x509 -req \
		-days 3650 -in leaf_revoked.csr -CA intermediate.crt \
		-CAkey intermediate.key -set_serial 0xAAAAAAAA -out leaf_revoked.crt \
		-extfile extfile_for_leaf_cert`

echo "====================================================="
echo "Generate good status leaf key/csr/cert"
eval `openssl req -new -nodes -out leaf_good.csr -keyout leaf_good.key \
		-subj '/C=US/L=San Jose/CN=leaf_good_cn' && openssl x509 -req -days 3650 \
		-in leaf_good.csr -CA intermediate.crt -CAkey intermediate.key \
		-set_serial 0x99999999 -out leaf_good.crt -extfile extfile_for_leaf_cert`

echo "====================================================="
echo "Generate CRL"
eval `openssl ca -gencrl -keyfile intermediate.key -cert intermediate.crt \
		-out myCrlFile.pem -config crl_openssl.cnf`

echo "====================================================="
echo "Converting CRL from PEM to DER"
eval `openssl crl -inform PEM -in myCrlFile.pem -outform DER -out myCrlFile.der`

echo "====================================================="
echo "Generate OCSP responder key/csr/cert"
eval `openssl req -new -nodes -out ocsp_responder.csr -keyout ocsp_responder.key \
		-subj '/C=US/L=San Jose/CN=ocsp_responder_cn' \
		-addext basicConstraints=CA:FALSE \
		-addext keyUsage=nonRepudiation,digitalSignature,keyEncipherment \
		-addext extendedKeyUsage=OCSPSigning && openssl x509 -req -days 3650 \
		-in ocsp_responder.csr -CA intermediate.crt -CAkey intermediate.key \
		-set_serial 0x1E -out ocsp_responder.crt \
		-extfile extfile_for_ocsp_responder_cert`
