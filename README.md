## Clone the repository
```
git clone https://github.com/eggburg/PKI-TestBed.git
cd PKI-TestBed/
```

## Regenerate the certs and CRL file (optional)

```
./regen_certs.sh
```

## Bring up the testbed environment

```
docker-compose up
```
Remark: if you want to run it in the background without printing logs, run "docker-compose up -d" instead


## Test from the SSL client container

Enter the SSL client container.
```
$ docker exec -it tls_client_container bash
```

### Test OCSP stapling
Send SSL connection to the SSL server that is using good certificate
```
bash-5.1# openssl s_client -connect tls.server.good:12345 -CAfile certs/root_intermediate.crt -status
```

Send SSL connection to the SSL server that is using good certificate
```
bash-5.1# openssl s_client -connect tls.server.revoked:54321 -CAfile certs/root_intermediate.crt -status
```

### Test CRL
Fetch CRL from the CRL distribution point, and use it to generate the crl chain file.
```
bash-5.1# curl -s http://crl.pki.eggburger/myCrlFile.pem > crl.pem
bash-5.1# cat certs/root_intermediate.crt crl.pem > crl_chain.pem
```

Fetch the good server's cert and verify it against the CRL
```
bash-5.1# openssl s_client -showcerts -connect tls.server.good:12345 2>/dev/null </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > good_server_certs
bash-5.1# openssl verify -crl_check -CAfile crl_chain.pem good_server_certs
good_server_certs: OK
```

Fetch the revoked server cert and verify it against the CRL
```
bash-5.1# openssl s_client -showcerts -connect tls.server.revoked:54321 2>/dev/null </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > revoked_server_certs
bash-5.1# openssl verify -crl_check -CAfile crl_chain.pem revoked_server_certs 
C = US, L = San Jose, CN = leaf_revoked_cn
error 23 at 0 depth lookup: certificate revoked
error server_cert: verification failed
```
