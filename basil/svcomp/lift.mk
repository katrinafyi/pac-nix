

OBJS = $(wildcard *.oi)
BINS = $(subst .oi,.out,$(OBJS))

RELFS = $(subst .out,.relf,$(BINS))
ADTS = $(subst .out,.adt,$(BINS))
GTS = $(subst .out,.gts,$(BINS))
OUTS = $(subst .out,_output.il,$(BINS))

BAP ?= bap
READELF ?= aarch64-unknown-linux-gnu-readelf
DDISASM ?= ddisasm
GTIRB_SEMANTICS ?= gtirb-semantics


all: $(RELFS) $(GTS) $(BINS)

%.out : %.oi
	$(CC) -O1 $< stubs.oc -o $@

%.adt : %.out
	$(BAP) $< -d adt:$@

%.relf : %.out
	$(READELF) $< -s -r -W > $@

%.gtirb : %.out
	$(DDISASM) $< --ir $@

%.gts : %.gtirb
	$(GTIRB_SEMANTICS) $< $@

#%_output.il : %.gts %.relf
#	java -jar assembly.dest/out.jar -i $< -r $(subst .gts,.relf,$<) --dump-il $(subst .gts,,$<) --simplify -v

