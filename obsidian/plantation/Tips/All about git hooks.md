#### pre-commit
The `pre-commit` script is executed every time you run `git commit` before Git asks the developer for a commit message or generates a commit object. You can use this hook to inspect the snapshot that is about to be committed. For example, you may want to run some automated tests that make sure the commit doesn’t break any existing functionality.

No arguments are passed to the `pre-commit` script, and exiting with a non-zero status aborts the entire commit.
#### prepare-commit-msg
The `prepare-commit-msg` hook is called after the `pre-commit` hook to populate the text editor with a commit message. This is a good place to alter the automatically generated commit messages for squashed or merged commits.

One to three arguments are passed to the `prepare-commit-msg` script:

1. The name of a temporary file that contains the message. You change the commit message by altering this file in-place.
2. The type of commit. This can be `message` (`-m` or `-F` option), `template` (`-t` option), `merge` (if the commit is a merge commit), or `squash` (if the commit is squashing other commits).
3. The SHA1 hash of the relevant commit. Only given if `-c`, `-C`, or `--amend` option was given.
#### commit-msg
The `commit-msg` hook is much like the `prepare-commit-msg` hook, but it’s called _after_ the user enters a commit message. This is an appropriate place to warn developers that their message doesn’t adhere to your team’s standards.

The only argument passed to this hook is the name of the file that contains the message. If it doesn’t like the message that the user entered, it can alter this file in-place (just like with `prepare-commit-msg`) or it can abort the commit entirely by exiting with a non-zero status.
#### post-commit
The `post-commit` hook is called immediately after the `commit-msg` hook. It can’t change the outcome of the `git commit` operation, so it’s used primarily for notification purposes.

The script takes no parameters and its exit status does not affect the commit in any way. For most `post-commit` scripts, you’ll want access to the commit that was just created. You can use `git rev-parse HEAD` to get the new commit’s SHA1 hash, or you can use `git log -1 HEAD` to get all of its information.
#### post-checkout
The `post-checkout` hook works a lot like the `post-commit` hook, but it’s called whenever you successfully check out a reference with `git checkout`. This is nice for clearing out your working directory of generated files that would otherwise cause confusion.

This hook accepts three parameters, and its exit status has no affect on the `git checkout` command.

1. The ref of the previous HEAD
2. The ref of the new HEAD
3. A flag telling you if it was a branch checkout or a file checkout. The flag will be `1` and `0`, respectively.
#### pre-rebase
The `pre-rebase` hook is called before `git rebase` changes anything, making it a good place to make sure something terrible isn’t about to happen.

This hook takes 2 parameters: the upstream branch that the series was forked from, and the branch being rebased. The second parameter is empty when rebasing the current branch. To abort the rebase, exit with a non-zero status.
#### pre-push
This hook is called by `git push` and can be used to prevent a push from taking place. The hook is called with two parameters which provide the name and location of the destination remote, if a named remote is not being used both values will be the same.

Information about what is to be pushed is provided on the hook’s standard input with lines of the form:

```bash
<local-ref> SP <local-object-name> SP <remote-ref> SP <remote-object-name> LF
```

For instance, if the command `git push origin master:foreign` were run the hook would receive a line like the following:

```bash
refs/heads/master 67890 refs/heads/foreign 12345
```

If this hook exits with a non-zero status, `git push` will abort without pushing anything. Information about why the push is rejected may be sent to the user by writing to standard error.

