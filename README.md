# My Dotfiles!

Welcome to my repository! Here you'll find my dotfiles, but not just plain dotfiles, a *[home-manager](https://nix-community.github.io/home-manager/) config*!

## Installation

### Requirements

- [Git](https://git.org)
- [Nix the package manager](https://nixos.org/download/)
- [Home Manager](https://nix-community.github.io/home-manager/)

For user-services I use [runit](https://smarden.org/runit) which is the default service supervisor of [Void Linux](https://voidlinux.org).

### Instruction

You've got the `home-manager`-command, which uses the default path `~/.config/home-manager`.

Remove this directory with as you want my config as a basis: 
```bash
$ rm -rf ~/.config/home-manager
```

Then clone this repository into just removed location with:
```bash
$ git clone https://github.com/friedelschoen/dotfiles ~/.config/home-manager
```

**IMPORTANT** Home Manager is curious about you and your home-directory. As your name probably isn't Friedel, change your username and homeDirectory in `home.nix` (these two lines are marked with '# EDIT ME').


Now the magic begins...!

Home Manager is respects you and your own configuration so you don't need to worry it removes files.

You can build this project with:
```bash
$ home-manager build
```

If everything went right, there should be a `./result`-directory (well actually a symbolic link to a directory but who asked). Congrats, youself just built your new home. It's time to move and make everything appear in place:
```bash
$ home-manager switch
```
