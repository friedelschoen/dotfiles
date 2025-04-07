result: *.json
	bake dotfiles.json

install: result
	rm -f ~/.dotfiles
	ln -sv $$(realpath -s --relative-to=$$HOME $$(readlink $^)) ~/.dotfiles
	stow -v -d ~/.dotfiles .
