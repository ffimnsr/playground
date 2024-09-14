Import the key:

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
```

Enable and add the repo:

```bash
sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge/

sudo dnf config-manager --add-repo 
https://packages.microsoft.com/yumrepos/vscode/
```

Refresh meta cache:

```bash
sudo dnf update --refresh
```

Install Microsoft Edge package:

```shell
sudo dnf install microsoft-edge-stable
```