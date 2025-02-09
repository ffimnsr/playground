If there's a problem on Github action runner service having a 203/Exec problem execute the code below:

```bash
chcon system_u:object_r:usr_t:s0 runsvc.sh
```

This is useful for systems that have SELinux enabled.

The `chcon` command is use to temporarily change SELinux attribute which can be viewed using `ls -lZ`.

#### References
- https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-security-enhanced_linux-working_with_selinux-selinux_contexts_labeling_files#sect-Security-Enhanced_Linux-SELinux_Contexts_Labeling_Files-Persistent_Changes_semanage_fcontext
