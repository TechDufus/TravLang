#**************************************************************************
#*                                                                        *
#*                                 travlang                                  *
#*                                                                        *
#*             Florian Angeletti, projet Cambium, Inria Paris             *
#*                                                                        *
#*   Copyright 2020 Institut National de Recherche en Informatique et     *
#*     en Automatique.                                                    *
#*                                                                        *
#*   All rights reserved.  This file is distributed under the terms of    *
#*   the GNU Lesser General Public License version 2.1, with the          *
#*   special exception on linking described in the file LICENSE.          *
#*                                                                        *
#**************************************************************************
# Used by included Makefiles
ROOTDIR = ..
-include ../Makefile.build_config

odoc-%:
	$(MAKE) -C odoc $*

travlangdoc-%:
	$(MAKE) -C travlangdoc $*

ifeq ($(DOCUMENTATION_TOOL),odoc)
man: odoc-man
latex: odoc-latex
html: odoc-html
	@echo "documentation is in ./api_docgen/odoc/build/html/"
all: html latex man
install: odoc-install
else
man: travlangdoc-man
latex: travlangdoc-latex
html: travlangdoc-html
	@echo "documentation is in ./api_docgen/travlangdoc/build/html/"
texi: travlangdoc-texi
pdf: travlangdoc-pdf
all: html pdf man latex texi
install: travlangdoc-install
endif

clean:
	rm -rf build odoc/build travlangdoc/build

distclean: clean

.PHONY: html latex man clean distclean install texi pdf
