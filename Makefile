result: *.json
	zon dotfiles.zon

install:
	rm -rf ~/.dotfiles
	cp -rL result ~/.dotfiles
	stow -v -d ~/.dotfiles .
