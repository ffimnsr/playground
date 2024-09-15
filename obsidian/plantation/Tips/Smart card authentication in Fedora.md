Install all necessary packages:

```bash
sudo dnf install -y sssd opensc pcscd
```

Next make sure the opensc module is loaded:

```bash
$ p11-kit list-module
# ...truncated output...
	opensc-pkcs11: opensc-pkcs11.so
	    library-description: OpenSC smartcard framework
	    library-manufacturer: OpenSC Project
	    library-version: 0.20
	    token: MARCO TREVISAN (PIN CNS0)
	        manufacturer: IC: STMicroelectronics; mask:...
	        model: PKCS#15 emulated
	        serial-number: 6090010669298009
	        flags:
	               login-required
	               user-pin-initialized
	               token-initialized
	               user-pin-locked
```

Next we extract smart card X.509 certificate into a file:

```
# Using opensc
pkcs15-tool --read-certificate 2 > card-cert.pem

# Using p11tool
p11tool --export 'pkcs11:id=%02;type=cert' > card-cert.pem
```

Check authority verification as this card must be allowed by a CA:

```
# List certificates
pkcs15-tool --list-certificates 
Using reader with a card: Alcor Micro AU9560 00 00
X.509 Certificate [CNS1]
	Object Flags   : [0x00]
	Authority      : no
	Path           : 3f00140090012002
	ID             : 02
	Encoded serial : 02 10 0357B1EC0EB725BA67BD2D838DDF93D5

# Extract the smart card cert to file
pkcs15-tool --read-certificate 2 > card-cert.pem

# See the certificate contents with
openssl x509 -text -noout -in card-cert.pem

# Verify it is valid for the given CA
openssl verify -verbose -CAfile CA-Auth-cert.pem card-cert.pem

# If only the parent CA Certificate is available, can use -partial_chain:
openssl verify -verbose -partial_chain -CAfile intermediate_CA_cert.pem
```

Configure the SSSD package:

```bash
sudoedit /etc/sssd/sssd.conf
```

Note: The config file must be owned by `root` and have permission set to `0600`, otherwise file won't be loaded by SSSD. To test if the configuration is correct, this command can launch a temporary daemon. After each successful configuration, the SSSD must be restarted.

```bash
sudo sssd -d9 -i
```

Since SSSD using openssl under the hood, we need to add the certificate to the SSSD well known certificate path (if not changed via `sssd.certificate_verification` option) as PEM format, so copying the CA certificates (can be a chain of certificates) to `/etc/sssd/pki/sssd_auth_ca_db.pem` should be enough:

```bash
sudo mkdir -p /etc/sssd/pki -m 600
sudo cat Ca-Auth-root-CERT.pem Ca-Auth-leaf-CERT.pem >> /etc/sssd/pki/sssd_auth_ca_db.pem
# ...or...
sudo cat Ca-Auth-CERT*.pem >> /etc/sssd/pki/sssd_auth_ca_db.pem
```

Enable pam in `sssd.conf`:

```text
[sssd]
services = pam

[pam]
pam_cert_auth = True
```

OPTIONAL: Certification Revocation List can be also defined in `sssd.conf`, providing a CRL file path in PEM format.

```text
[sssd]
crl_file = /etc/sssd/pki/sssd_auth_crl.pem
soft_crl = /etc/sssd/pki/sssd_auth_soft_crl.pem
```

In case that a full certificate authority chain is not available, openssl won’t verify the card certificate, and so sssd should be instructed about.

This is not suggested, but it can be done changing `/etc/sssd/sssd.conf` so that it contains:

```text
[sssd]
certificate_verification = partial_chain
```

OPTIONAL: To define a custom ca-certificates path:

```text
[pam]
pam_cert_db_path = /etc/ssl/certs/ca-certificates.crt
```

The card certificate validation can be simulated using SSSD tools directly, by using the command SSSD's p11_child:

```bash
sudo /usr/libexec/sssd/p11_child --pre -d 10 --debug-fd=2 --ca_db=/etc/sssd/pki/sssd_auth_ca_db.pem
```

If the certificate verification succeeds, the tool should output the card certificate name, its ID and the certificate itself in base64 format (other than debug data):

```text
(Mon Sep 11 16:33:32:129558 2023) [p11_child[1965]] [do_card] (0x4000): Found certificate has key id [02].
MARCO TREVISAN (PIN CNS1)
/usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so
02
CNS1
MIIHXDCCBUSgAwIBAgIQA1ex7....
```

For checking if the smartcard works, without doing any verification check (and so for debugging purposes the option) `--verify=no_ocsp` can also be used, while `--verify=partial_chain` can be used to do partial CA verification.

#### References:
- https://ubuntu.com/tutorials/how-to-use-smart-card-authentication-in-ubuntu-desktop
- https://ubuntu.com/server/docs/smart-card-authentication#x509-smart-card-certificates