SUBDIRS = suckless/dmenu suckless/dwm suckless/slstatus suckless/st suckless/stagit

.PHONY: all $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@
