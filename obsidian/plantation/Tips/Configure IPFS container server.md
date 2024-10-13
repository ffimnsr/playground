Use profile server to limit netscan that can be considered abuse on hosting providers.

```bash
IPFS_PROFILE=server
```

Some config for public ipfs gateway, to restrict file access to local files stored on node:

```bash
ipfs config --bool Gateway.NoFetch true
```

