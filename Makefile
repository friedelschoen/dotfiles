result: *.json
	zon dotfiles.zon

install: result
	rm -rf ~/.dotfiles
	cp -rL result ~/.dotfiles
	stow -v -d ~/.dotfiles .
