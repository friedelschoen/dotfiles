# My Dotfiles!

## Installing

### Step 1

Install dependencies:
- `git`
- `stow` (optional)
- `make`
- suckless-dependencies

### Step 2

Clone this repository with:

```bash
~ $ git clone --recurse-submodules https://git.friedelschoen.io/dotfiles
```

Or if you forget the use the `--recurse-submodules`-flag, you can update the submodules afterwards:

```bash
~ $ git submodule update --init
```

And finally change you working directory with:

```bash
~ $ cd dotfiles
```

### Step 3

You can populate the dotfiles with GNU stow:

```bash
~/dotfiles $ stow . 
```

This will link every file in this repository to the parent directory, e.g. `~/dotfiles/.zshrc -> ~/.zshrc`.
If you are using `stow`, ensure you have cloned this repository into your home-directory or use the `-t <target>` flag, more info about stow in `stow(1)`.

You can also manually copy or link the files you want.

### Step 4

Build all suckless-configurations with `make`, there is a `Makefile` provided to build all subdirectories:

```bash
~/dotfiles $ make [suckless-progs]
```
