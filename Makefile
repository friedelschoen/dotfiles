SOURCES = sources.txt
STOWDIR = dotfiles
FETCHDIR = sources

EXTRA = \
	$(STOWDIR)/.config/bgglenda.png

# --- PHONIES ---

.PHONY: stow clean purge

stow: $(STOWDIR) $(EXTRA)
	stow -v $(STOWDIR)

clean:
	rm -rf $(FETCHDIR)

purge: clean
	rm -rf $(EXTRA)

# --- DIRECTORIES ---

$(FETCHDIR):
	mkdir -p $@

# --- SOURCES ---

$(FETCHDIR)/%: | $(FETCHDIR)
	./scripts/fetch.awk -v out=$* sources.txt

# --- GENERATED ---

$(STOWDIR)/.config/bgglenda.png: $(FETCHDIR)/spaceglenda.png | $(STOWDIR)
	magick convert -resize 12.5% $< $@
