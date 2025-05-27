SOURCES = sources.txt
STOWDIR = stowdir
FETCHDIR = sources

# --- PHONIES ---

.PHONY: stow clean purge

stow: $(STOWDIR) $(STOWDIR)/.config/bgglenda.png
	stow -v $(STOWDIR)

clean:
	rm -rf $(FETCHDIR)

purge: clean
	rm -rf $(STOWDIR)

# --- DIRECTORIES ---

$(STOWDIR): dotfiles
	cp -r $< $@

$(FETCHDIR):
	mkdir -p $@

# --- SOURCES ---

$(FETCHDIR)/%: | $(FETCHDIR)
	awk '/\s*#/ {next} $$2 == "$*" { print $$1 $$3 }' $(SOURCES)
#	wget -O $@ https://github.com/9fans/plan9port/raw/afea5fc3fd16a2865d0af52563f601a4c03d8256/mac/spaceglenda.png

# --- GENERATED ---

$(STOWDIR)/.config/bgglenda.png: $(FETCHDIR)/spaceglenda.png | $(STOWDIR)
	magick convert -resize 12.5% $< $@
