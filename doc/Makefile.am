doc_DATA = index.html installation.html assembler.html io.html \
					 aiscm.gif construction.gif

EXTRA_DIST = index.md.in installation.md.in assembler.md io.md construction.gif aiscm.gif

CLEANFILES = *~ *.html

MAINTAINERCLEANFILES = Makefile.in index.md installation.md

.md.html:
	$(PANDOC) -s -f markdown -t html $< > $@
