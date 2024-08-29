Syslog Message Levels For Errors

```
0: emerg
1: alert
2: crit
3: err
4: warning
5: notice
6: info
7: debug
```

To filter by priority.

```bash
journalctl -p err
```

To filter by priority range.

```bash
journalctl -p emerg..err
```

To view kernel messages (like dmesg).

```bash
journalct -k
```

To view boot logs.

```bash
journalctl -b
```

To view boot logs for this day.

```bash
journalctl -b -S today
```

To view last boot log.

```bash
journalctl -b -1
```

To see the boots journald knows about.

```bash
journalctl --list-boots
```

To filter logs by unit files.

```bash
journalctl -u docker.service
```

To jump to the end of the journal.

```bash
journalctl -e
```

To jump to end of journal and follow.

```bash
journalctl -ef
```

To reverse the journal newest first.

```bash
journalctl -r
```

To add relevant information or message explanation when available.

```bash
journalctl -x
```

To show only number of journal entries.

```bash
journalctl -n 20
```
