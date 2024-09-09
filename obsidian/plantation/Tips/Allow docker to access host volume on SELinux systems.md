To allow access to a host mounted directory in guess os, you need to append at the endp of mount point this `:z` or `:Z`. 

If it still does not work then run the following command at the bottom which does the same thing.

```bash
chcon -Rt svirt_sandbox_file_t <dir or file>
```
