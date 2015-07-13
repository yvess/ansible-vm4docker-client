#!/bin/sh

mkdir -p ~/.vm4docker/certs
cd ~/.vm4docker/certs
source ~/.profile
/usr/local/opt/openssl/bin/openssl genrsa -aes256 -passout pass:vm4docker -out ca-key.pem 2048
/usr/local/opt/openssl/bin/openssl req -new -x509 -days 365 -key ca-key.pem \
  -passin pass:vm4docker -sha256 \
  -subj '/CN=$DOCKER_HOSTIP/O=vm4docker/C=US' \
  -out ca.pem
/usr/local/opt/openssl/bin/openssl genrsa -out server-key.pem 2048
/usr/local/opt/openssl/bin/openssl req -subj "/CN=$DOCKER_HOSTIP" \
  -new -key server-key.pem -out server.csr
echo subjectAltName = IP:$DOCKER_HOSTIP,IP:127.0.0.1 > extfile.cnf
/usr/local/opt/openssl/bin/openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out server-cert.pem -passin pass:vm4docker -extfile extfile.cnf
/usr/local/opt/openssl/bin/openssl genrsa -out key.pem 2048
/usr/local/opt/openssl/bin/openssl req -subj '/CN=client' -new -key key.pem -out client.csr
echo extendedKeyUsage = clientAuth > client_extfile.cnf
/usr/local/opt/openssl/bin/openssl x509 -req -days 365 -in client.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out cert.pem -passin pass:vm4docker -extfile client_extfile.cnf

rm -v client.csr server.csr
chmod -v 0400 ca-key.pem key.pem server-key.pem
chmod -v 0444 ca.pem server-cert.pem cert.pem
