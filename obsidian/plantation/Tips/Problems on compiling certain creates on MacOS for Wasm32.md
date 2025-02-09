
The reason why it doesn't compile is its using the Xcode LLVM. So to solve this we need to install LLVM itself using homebrew.

Install the LLVM from brew as if not it will use clang from Xcode:

```bash
brew install llvm
```

Then set the export paths:

```bash
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export CC=/opt/homebrew/opt/llvm/bin/clang
export AR=/opt/homebrew/opt/llvm/bin/llvm-ar
```

or for intel macs:

```bash
export PATH="/usr/local/opt/llvm/bin:$PATH"
export CC=/usr/local/opt/llvm/bin/clang
export AR=/usr/local/opt/llvm/bin/llvm-ar
```


