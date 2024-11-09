This assumes the scenario is you have a `feat-branch` and want to merge latest changes from `origin/main` but have created a divergence.

To fix this, you need to reset the feature branch:

```bash
git co feat-branch
git reset --hard origin/main
...
git cherry-pick <your-commit-hash>
git cherry-pick <your-another-commit-hash>
```

Another way would be to use `format-patch`:

```bash
git co feat-branch
git format-patch -M origin/main
git reset --hard origin/main
...
git am 0001-<commit-hash>.patch
git am 0002-<commit-hash>.patch
```
#### References
- https://stackoverflow.com/a/8716401