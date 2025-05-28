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
	./scripts/fetch.awk -v out=$* sources.txt

# --- GENERATED ---

$(STOWDIR)/.config/bgglenda.png: $(FETCHDIR)/spaceglenda.png | $(STOWDIR)
	magick convert -resize 12.5% $< $@
