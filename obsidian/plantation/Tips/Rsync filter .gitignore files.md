This is how to rsync filtering `.gitignore` included files

```bash
rsync -azP --filter=":- .gitignore" --exclude=".git" . houz-gg:~/daily-committer
```
