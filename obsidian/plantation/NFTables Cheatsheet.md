Hooks:

![[Pasted image 20241118123911.png]]

Viewing ruleset:

```bash
sudo nft list ruleset
```

Viewing ruleset with handles:

```bash
sudo nft -a list ruleset
```

It can also be granular like viewing tables to actual chain:

```bash
sudo nft -a list table inet firewall
sudo nft -a list chain inet firewall inbound
```

Inserting rule at a certain handle position (this will insert before the handle):

```bash
sudo nft insert rule inet firewall inbound position 32 tcp dport 80 accept
```

Example of creating a table to rule:

```bash
flush ruleset
add table filter
add chain filter input
add rule filter input meta iifname lo accept
```

Tables format:

```bash
% nft list tables [<family>]
% nft [-n] [-a] list table [<family>] <name>
% nft (add | delete | flush) table [<family>] <name>
```

Chains format:

```bash
% nft (add | create) chain [<family>] <table> <name> [ \{ type <type> hook <hook> [device <device>] priority <priority> \; [policy <policy> \;] \} ]
% nft (delete | list | flush) chain [<family>] <table> <name>
% nft rename chain [<family>] <table> <name> <newname>
```

Rules format:

```bash
% nft add rule [<family>] <table> <chain> <matches> <statements>
% nft insert rule [<family>] <table> <chain> [position <handle>] <matches> <statements>
% nft replace rule [<family>] <table> <chain> [handle <handle>] <matches> <statements>
% nft delete rule [<family>] <table> <chain> [handle <handle>]
```

Priority NFTables reference:

![[Pasted image 20241118124014.png]]