Before doing any of the following below you must create it on a safe environment, which is a clone repo.

```bash
git clone --no-hardlinks <original-repo> <clone-repo>
# ..e.g...
git clone --no-hardlinks folder-repo cloned-folder-repo
```
#### Using `filter-repo` (GitHub preferred)
If you create a new clone of the repository, you won't lose any of your Git history or changes when you split a folder into a separate repository. However, note that the new repository won't have the branches and tags of the original repository.

To filter out the subfolder from the rest of the files in the repository, install [`git-filter-repo`](https://github.com/newren/git-filter-repo), then run `git filter-repo` with the following arguments.

```bash
git filter-repo --path FOLDER-NAME/
```

This filters the specified branch in your directory and remove empty commits. The repository should now only contain the files that were in your subfolder(s).

If you want one specific subfolder to be the new root folder of the new repository, you can use the following command:

```bash
git filter-repo --subdirectory-filter FOLDER-NAME
```

This filters the specific branch by using a single sub-directory as the root for the new repository.

Then add attach a remote repo url to the filtered repo.
#### Using subtree split
Using the git subtree function, you can easily split a subdirectory out to a new branch, create and link the new repository then push it.

```bash
cd ~/big-repo
git subtree split -P my-folder -b my-folder
```

The name of the folder must be a relative path, starting from the root of the repository. This will create a new branch which contains the subfolder.

Next thing to do is initialize an empty repo on a new folder. Then pull branch from the original repo to the newly init repo.

```bash
cd ~/new-my-folder
git init
git pull ~/big-repo my-folder
git remote add origin git@github.com:user/my-folder.git
git push origin -u main
```

After that remove remnants of the subfolder.

```bash
cd ~/big-repo
git rm -rf my-folder
git branch -d my-folder
git commit -m "remove my-folder"
git push
```
#### Using git filter-branch
This `git filter-branch` is another way of doing things retaining the original git history.

```bash
git checkout -b some-branch
git filter-branch --prune-empty --subdirectory-filter <subfolder-to-keep> some-branch
```