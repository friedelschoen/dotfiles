# Friedel's Dotfiles

My personal dotfiles, managed declaratively with [Bake](https://github.com/friedelschoen/bake) and symlinked using [GNU Stow](https://www.gnu.org/software/stow/).

This setup allows for reproducible, modular configuration management across different systems and environments.

## Features

- 🧁 Built with [Bake] – a simple JSON-based build system
- 🔗 Uses [GNU Stow] for symlink-based home directory management
- 🧹 Clean, minimal configuration grouped by purpose
- 🐧 Easily portable across machines and distributions
- 🧪 Declarative structure for better reproducibility and maintainability

## Structure

Your dotfiles are organized into subdirectories, each representing a module or application (e.g., `vim/`, `zsh/`, `x/`, etc). Each subdirectory is designed to be managed independently using Stow.

```bash
dotfiles/
├── bake.json        # Bake config to install/sync dotfiles
├── zsh/             # zsh config files
├── vim/             # vim config files
├── x/               # X11 config files
├── ...
```

## Usage

### 1. Clone this repo

```sh
git clone https://github.com/friedelschoen/dotfiles.git
```

### 2. Build with Bake

There is a [justfile](https://github.com/casey/just) provided with useful commands. For building just run

```sh
just build
```

### 3. Link with GNU Stow

If everything went fine, you should have a `result` directory (symlink actually). To apply everything:

```sh
just stow
```

Or use `stow` manually.

## License

This project is licensed under the [zlib License](https://opensource.org/licenses/Zlib):