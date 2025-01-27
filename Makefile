install: build/home
	scripts/symlink.py $$HOME build/home

uninstall:
	scripts/symlink.py -u $$HOME

clean:
	rm -rf build

build/apps build/sources: apps.yml
	scripts/makeapps.py $^

build/services: services.yml
	scripts/makeservices.py $^

build/home: build/apps build/services dotfiles
	rm -rf build/home/
	cp -r dotfiles build/home/
	cp -r build/service build/home/.xservice/
	cp -r build/apps build/home/.local/

