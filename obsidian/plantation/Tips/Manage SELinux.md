To find the most recent (within 10 mins) selinux errors.

```bash
sudo ausearch -m AVC,USER_AVC,SELINUX_ERR -ts recent
```

To generate allow policy package.

```bash
sudo ausearch -c firewalld --raw | audit2allow -M ifn4-firewalld
semodule -i ifn4-firewalld.pp
```

To make permanent change in the selinux label.

```bash
sudo semanage fcontext -a -t firewalld_t /var/log/firewalld
```

To restore it to the correct label on which the one you set using `semanage`.
This command will be **NEEDED** to run after setting or running `semanage fcontext`.

```
sudo restorecon -rv /var/log/firewalld
```

To make temporary change in the selinux label.

```bash
sudo chcon -R -t firewalld_t /var/log/firewalld
```