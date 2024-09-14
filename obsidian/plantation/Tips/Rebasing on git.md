A **rebase** allows us to move branches around by changing the commit that they are based on.

Checkout your branch first:

```bash
git checkout featured-x
```

After creating your multiple commits on a featured branch. We need to compress/squash the branch commits into 1 commit.

```bash
git rebase -i HEAD~n
```

This assume you know how many commits you are from the base of your branch. In case you don't know you can run this command to get the commit hash which can be use.

```bash
git merge-base <my-branch> <base-branch>

#...e.g...
git merge-base feature-x main
```

Then we can proceed with the commit hash like this:

```bash
git rebase -i <commit-hash>
```

To complete the rebase execute the code below (if there were conflicts fix it first):

```bash
# Update main branch before doing any rebase
git fetch
git checkout main
git pull

# Rebase
git checkout featured-x
git rebase origin/main
```

If there were conflicts fix it with merge tool then continue on rebase:

```bash
git rebase --continue
```

To recover lost commits you can reflog (reference log):

```bash
git reflog
```

Once the branch has been accepted you can now follow the workflow below which will delete the branch locally.

```bash
git checkout main
git pull --rebase origin main
git push -f origin main
git branch -d featured-x
git push origin --delete featured-x
```
