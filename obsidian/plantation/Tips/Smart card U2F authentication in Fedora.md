Install the U2F packages:

```bash
sudo dnf install pam-u2f pamu2fcfg
```

OPTIONAL: If in any case the workstation can't find the Yubikey as U2F device. You may need to install `libu2f-udev` (on debian) or download this udev rule:

```bash
sudo wget https://raw.githubusercontent.com/Yubico/libu2f-host/master/70-u2f.rules -O /etc/udev/rules.d/70-u2f.rules
```

Create two configuration files in `/etc/pam.d/u2f-required` and `u2f-sufficient`:

```bash
#%PAM-1.0
auth required pam_u2f.so
```

```bash
#%PAM-1.0
auth sufficient pam_u2f.so
```

**Note**: If you have moved the u2f_keys file to /etc/Yubico/u2f_keys as mentioned in section 3, you will need to append authfile and a path to the PAM configuration, as shown below:

```bash
auth required pam_u2f.so authfile=/etc/Yubico/u2f_keys
```

For those who forget that the Yubikey is set up for the workstation you can add a cue to `/etc/pam.d/sudo` to give you a message, instead of just the paused prompt.

```bash
auth sufficient pam_u2f.so cue [cue_prompt=Tap the yubikey to sudo]
```

See here for more info: https://developers.yubico.com/pam-u2f/#:~:text=%5Bcue_prompt%3Dyour%20prompt%20here%5D

Use the tool pamu2fcfg to retrieve a configuration line that goes into ~/.config/Yubico/u2f_keys. This configuration line consists of a username and a part tied to a key separated by colon.

```bash
mkdir -p ~/.config/Yubico
pamu2fcfg > ~/.config/Yubico/u2f_keys
```

If you have a backup key add it with the --nouser option and append it to the existing key (line). (All output should end up in the same line.)

```
pamu2fcfg -n >> ~/.config/Yubico/u2f_keys
```

Next configure PAM to accept a YubiKey as a means of authentication. There are many options in /etc/pam.d to modify and add a YubiKey, but the most common use-cases are:

- /etc/pam.d/login
- /etc/pam.d/gdm-password
- /etc/pam.d/lightdm
- /etc/pam.d/sudo
- /etc/pam.d/sudo-i
- /etc/pam.d/sshd (non-u2f using `pam-yubico`)
- /etc/pam.d/runuser
- /etc/pam.d/runuser-l
- /etc/pam.d/su
- /etc/pam.d/su-l

In a PAM configuration file if using `u2f-sufficient` add an include line before or if using `u2f-required` add it after a line that reads `auth substack system-auth` or `auth include system-auth`.

```bash
auth include system-auth
auth include u2f-required
...or...
auth include u2f-sufficient
auth include system-auth
```

**Note**: If you add the YubiKey as a factor in sudo authentication, make certain to have a root shell open and test it thoroughly in another shell. Otherwise you could lose the ability to use sudo.

**DON'T close yet the terminal.** Always test the configuration, to test open a new terminal and execute `sudo echo SUCCESS`.

For login:
- /etc/pam.d/gdm-password

For TTY terminal:
- /etc/pam.d/login

#### References:
- https://fedoramagazine.org/how-to-use-a-yubikey-with-fedora-linux/
- https://docs.fedoraproject.org/en-US/quick-docs/using-yubikeys/