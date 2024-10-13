This clones the SNES directory in Myrient it's similar to having a list of URLs but using html.

```bash
rclone copy :http: ./Games-SNES --http-url 'https://myrient.erista.me/files/No-Intro/Nintendo%20-%20Super%20Nintendo%20Entertainment%20System/' --http-no-head --ignore-existing -v
```

What this does, is feed all the URL from the captured HTML to `rclone` the copies it to desired directory.