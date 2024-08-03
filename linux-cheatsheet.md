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
