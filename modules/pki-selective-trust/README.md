# PKI Selective Trust

## Keys and certificates in this directory

In NixOS, certificate bundles are built as derivation.
Therefore, we would want them to be determinstically produced.
For doing so, we cannot generate a key on each host.
Therefore a key is generated here, so is the corresponding root certificate.

Security-wise, this is fine.
Signatures of certificates added to the trust store does not matter, and we never add the certificate in this directory itself to the trust store.

The private key is generated via
```
openssl genrsa -out root.key 4096
```

and the certificate is generated via
```
openssl req -x509 -new -nodes -key root.key -sha256 -days 36500 -out root.pem -subj '/CN=Local Machine Root CA'
```
