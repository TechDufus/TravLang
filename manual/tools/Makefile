ROOTDIR = ../..
include $(ROOTDIR)/Makefile.common
include $(ROOTDIR)/Makefile.best_binaries

travlangC ?= $(BEST_travlangC) $(STDLIBFLAGS)

all: texquote2 transf


transf: transf.cmo transfmain.cmo
	$(travlangC) $(COMPFLAGS) -o $@ -g $^

transfmain.cmo: transf.cmo

texquote2: texquote2.ml
	$(travlangC) $(COMPFLAGS) -o $@ $<

%.cmo: %.ml
	$(travlangC) $(COMPFLAGS) -c $<

%.cmi: %.mli
	$(travlangC) $(COMPFLAGS) -c $<

.PHONY: clean
clean:
	rm -f *.o *.cm? *.cmx?
	rm -f transf.ml
	rm -f texquote2 transf

.PHONY: distclean
distclean: clean
