result: *.json
	bake dotfiles.json

install: result
	rm -rf ~/.dotfiles
	cp -rL result ~/.dotfiles
	stow -v -d ~/.dotfiles .
