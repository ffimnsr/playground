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
#### Additional shell parameter expansion from Bash

Beginning - `${parameter#word}`, `${parameter##word}`

```text
The word is expanded to produce a pattern and matched according to the rules described below (see [Pattern Matching](https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)). If the pattern matches the beginning of the expanded value of parameter, then the result of the expansion is the expanded value of parameter with the shortest matching pattern (the ‘#’ case) or the longest matching pattern (the ‘##’ case) deleted. If parameter is ‘@’ or ‘*’, the pattern removal operation is applied to each positional parameter in turn, and the expansion is the resultant list. If parameter is an array variable subscripted with ‘@’ or ‘*’, the pattern removal operation is applied to each member of the array in turn, and the expansion is the resultant list.
```

Trailing - `${parameter%word}`, `${parameter%%word}`

```text
The word is expanded to produce a pattern and matched according to the rules described below (see [Pattern Matching](https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)). If the pattern matches a trailing portion of the expanded value of parameter, then the result of the expansion is the value of parameter with the shortest matching pattern (the ‘%’ case) or the longest matching pattern (the ‘%%’ case) deleted. If parameter is ‘@’ or ‘*’, the pattern removal operation is applied to each positional parameter in turn, and the expansion is the resultant list. If parameter is an array variable subscripted with ‘@’ or ‘*’, the pattern removal operation is applied to each member of the array in turn, and the expansion is the resultant list.
```

Example:

```bash
$ prefix="hell"
$ suffix="ld"
$ string="hello-world"
$ foo=${string#"$prefix"}
$ echo $foo
o-world
$ foo=${foo%"$suffix"}
$ echo $foo
o-wor
```
#### References:
- https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
- https://tldp.org/LDP/abs/html/string-manipulation.html