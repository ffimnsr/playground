#### FIDO2
Using FIDO2 and OpenSSH 8.2+ you can generate OpenSSH keys that are only usable if the YubiKey is connected. It’s possible to protect the key usage by either presence or presence + pin-entry.

Use OpenSSH **ssh-keygen** to generate a public key you can later use in **authorized_keys** files on remote systems. The following generates such a key directly on the YubiKey in a FIDO2 slot, making it portable.

```bash
ssh-keygen -t ed25519-sk -O resident -O application=ssh:fedora -O verify-required
```

The **resident** option instructs ssh-keygen to store the key handle on the YubiKey, making it easier to use the key across multiple systems as **ssh-add** can load and use the ssh keys from the YubiKey directly. The **application** option assigns a designated name for the this specific private-public-key-pair and is useful if working with different ssh identities. The **verify-required** option is mandatory for **resident** keys and adds requirement to enter a pin on key usage.

If you did not set a FIDO2 pin on the key omit the verify-required flag. If you don’t want to use **FIDO2** slots, omit the **resident** and **application** options and make sure to backup generated public keys.
#### PKCS11
YubiKey can store OpenSSH private keys in the PIV module, generate public keys from them, and require PIN and touch of the YubiKey button upon use.

- 9A - PIV Authentication
- 9C - Digital Signature
- 9D - Key Management
- 9E - Card Authentication

Generate a private key (e.g. ED25519) with touch and pin requirement in the **9a** [slot](https://docs.yubico.com/yesdk/users-manual/application-piv/slots.html):

```bash
ykman piv keys generate --algorithm ED25519 --pin-policy ONCE --touch-policy ALWAYS 9a public.pem
```

Create a self-signed certificate for that key. The only use for the X.509 certificate is to satisfy PIV/PKCS #11 lib. It is needed to extract the public key from the smart card.

```bash
ykman piv certificates generate --subject "CN=OpenSSH" --hash-algorithm SHA384 9a pubkey.pem
```

Generate a public key from the X.509 certificate stored on the YubiKey.

```bash
ssh-keygen -D /usr/lib/libykcs11.so -e
```

Login to systems with this public key:

```bash
ssh -I /usr/lib/libykcs11.so user@remote.example.org
```

The ssh-agent may also load keys from the YubiKey with:

```bash
ssh -s /usr/lib/libykcs11.so
```

