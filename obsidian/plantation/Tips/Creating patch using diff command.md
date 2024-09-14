To create a patch for a single file:

```bash
diff -u <original-file> <updated-file> > <patch-file>
```

Apply patch to a file:

```bash
patch <original-file> < <patch-file>
```

Revert a patch:

```bash
patch -R <original-file> < <patch-file>
```

To create a patch for a directory:

```bash
diff -ruN <original-dir> <updated-dir> > <patch-file>
```

The `-r` argument means to recursively compare any sub directory found. Then `-u` creates a diff file in unified format, lastly `-N` treats absent files as empty.

Apply patch to the directory:

```bash
patch -p0 < <patch-file>
```

The `-p0` applies the patch to the same directory structure as when the patch created. The `-p` strip the smallest prefix.

```text
# Using p0 gives the entire file name unmodified
/home/path/to/file.txt
# p1
home/path/to/file.txt
# p2
path/to/file.txt
# p3
to/file.txt
# p4
file.txt
```

And as always you can use `-b` to create backup before patching. A good rule of the thumb is doing dry-runs using `--dry-run` flag.

Revert patching of directory:

```bash
patch -R -p0 <original-dir> < <patch-file>
```