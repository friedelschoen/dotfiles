# Friedel's Dotfiles

Hello, you've somehow landed here. These are my dotfiles! They're managed using GNU Make and some scripts; automatically downloading some sources and a preprocessor.

## Requisite

### Building

- [GNU Make](https://www.gnu.org/software/make/) ([BSD make](https://man.freebsd.org/cgi/man.cgi?make(1)) is untested, probably works too)
- [GNU AWK](https://www.gnu.org/software/gawk/) ([BSD awk](https://man.freebsd.org/cgi/man.cgi?awk(1)) is untested)
- [curl](https://curl.se/)
- [python3](https://www.python.org/)

### Runtime

Software I configure with my dotfiles:

- shell: [fish](https://fishshell.com/)
- compositor: [sway](https://swaywm.org/)
- terminal: [foot](https://codeberg.org/dnkl/foot)
- editor: [micro](https://micro-editor.github.io/)
- statusbar: [st8](https://github.com/friedelschoen/st8/)

## Preprocessor

Files in dotfiles will be passed through a preprocessor if it has a `.in`-extension.

### Commands

### `@@ ...`

This is a comment, this line is ignored

### `@define <name> <text...>`

Defines variable _name_ as _text_. The content is preprocessed when defining.

### `@include <file>`

Includes the file, this file preprocessed.

### `@ifeq <var> <text...>`, `@ifneq <var> <text...>`

Tests if variable is equal to or not equal to text. Lines are printed until `@else` or `@endif`.

## Contributing

Feel free to post question or issues or make a pull-request!

## License

This project is licensed under the [zlib License](https://opensource.org/licenses/Zlib):