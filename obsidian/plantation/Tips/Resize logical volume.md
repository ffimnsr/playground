To resize a logical volume for example in Debian where all the remaining allocation has been put to ***home*** logical volume. First logout and enter as root, then reduce home allocation.

```bash
lvreduce --resizefs -L-100G ifn2-vg/home
```

After reducing the *home* logical volume, resize the logical volume that you want to increase for my case it will be *root* logical volume.

```bash
lvresize --resizefs -L+100G ifn2-vg/root
```

That's all.