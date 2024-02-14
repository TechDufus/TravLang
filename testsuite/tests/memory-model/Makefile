ROOTDIR = ../../..

include $(ROOTDIR)/Makefile.common
include $(ROOTDIR)/Makefile.best_binaries

travlangC ?= $(BEST_travlangC) $(STDLIBFLAGS)
travlangOPT ?= $(BEST_travlangOPT) $(STDLIBFLAGS)

PGM=forbidden.exe publish.exe
MOREPGM=
MOREBYT=$(MOREPGM:.exe=.byt)
BYT=$(PGM:.exe=.byt)
CMO=$(PGM:.exe=.cmo)
CMX=$(PGM:.exe=.cmx)
OBJ=opt.cmx barrier.cmx hist.cmx shared.cmx run.cmx outcome.cmx
BBJ=$(OBJ:.cmx=.cmo)
SRC=$(OBJ:.cmx=.ml) $(PGM:.exe=.ml) $(MOREPGM:.exe=.ml)
MLI=$(OBJ:.cmx=.mli)

all: native byte

native: $(PGM)

byte: $(BYT)

clean::
	/bin/rm -f $(MOREPGM) $(MOREBYT) $(BYT) $(PGM) *.cmo *.cmi *.cmx *.o *~ *.s

%.cmx: %.ml
	$(travlangOPT) -c $<

%.cmo: %.ml
	$(travlangC) -c $<

%.cmi: %.mli
	$(travlangC) -c $<

%.s: %.ml
	$(travlangOPT) -S -c $<

%.exe: %.cmx $(OBJ)
	$(travlangOPT) -o $@ $(OBJ) $<

%.byt: $(BBJ) %.cmo
	$(travlangC) -o $@ $^

depend:
	$(travlangDEP_CMD) $(SRC) $(MLI) > .depend

-include .depend
