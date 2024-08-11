Display one specific line of the file to terminal:

```bash
sed -n 5p <FILE>
```

Print multiple lines of the file to terminal (line 5 and 10):

```bash
sed -n -e 5p -e 10p <FILE>
```

Print a range of lines of the file to terminal (lines 5 to 10):

```bash
sed -n 5,10p <FILE>
```

Image to base64 (single-line) bash variable:

```bash
IMAGE_B64=$(base64 -w 0 <IMAGE>)
```

Create virtual env in python:

```bash
python3 -m venv <ENV_NAME>
```

Format disk to btrfs:

```bash
sudo fdisk /dev/<DISK>
sudo mkfs.btrfs -f -L <LABEL> /dev/<DISK>
```
