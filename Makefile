all: build/home

install: build/home
	scripts/symlink.py $$HOME build/home

uninstall:
	scripts/symlink.py -u $$HOME

clean:
	rm -rf build

.PHONY: build/apps build/sources
build/apps build/sources:
	scripts/makeapps.py apps.yml

.PHONY: build/services
build/services:
	scripts/makeservices.py services.yml

build/home: build/apps build/services dotfiles
	rm -rf build/home/
	cp -r dotfiles build/home/
	cp -r build/service build/home/.xservice/
	cp -r build/apps build/home/.local/

