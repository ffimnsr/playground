- `!$` or `!:$` - the last argument
- `!^` or `!:^` - first argument (after the program/script/built-in command) from previous command
- `!*` - all arguments from the previous command
- `!!` - previous command including arguments
- `!n` - command number `n` from **history**.
- `!str` - most recent command **starting** with `str`
- `!?str[?]` - most recent command **containing** `str`
- `!!:s/find/replace[/:G]` - previous (last) command, substitute `find` with `replace`
- `!!:1` - get the previous command first argument
- `!!:1-2` - get the previous command first and second argument
- `!!:0` - get the previous command only
- `!#` - get **current** command line typed in so far (duplicate the current command)

Note:
For word designators a `:` usually separates the event specification from the word designator. It may be omitted only if the word designator begins with a `^`, `$`, `*`, `-`, or `%`.