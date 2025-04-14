This clones the SNES directory in Myrient it's similar to having a list of URLs but using html.

```bash
rclone copy :http: ./Games-SNES --http-url 'https://myrient.erista.me/files/No-Intro/Nintendo%20-%20Super%20Nintendo%20Entertainment%20System/' --http-no-head --ignore-existing -v
```

What this does, is feed all the URL from the captured HTML to `rclone` the copies it to desired directory.

To clone `archive.org`:

```bash
rclone copy :http: ./queen-1 --http-url 'https://archive.org/download/queen_greatest-hits_202310/Queen/Greatest%20Hits%20I%2CII%2CIII%20%28FLAC%29/Queen%20-%20Greatest%20Hits%20%282011%29%20%5BEAC%20FLAC%5D%20%5BJapan%20SHM-CD%2C%20UICY-15001%5D/' --http-no-head --ignore-existing -v --include "*.flac" --dry-run
```
