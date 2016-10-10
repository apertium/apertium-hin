###############################################################################
## Makefile for apertium-hin
###############################################################################

RELEASE=0.1
VERSION=0.1.0
LANG1=hin
BASENAME=apertium-$(LANG1)

TARGETS_COMMON = $(LANG1).automorf.bin $(LANG1).autogen.bin \
	$(LANG1).automorf.att.gz $(LANG1).autogen.att.gz \
        $(LANG1).rlx.bin

# This include defines goals for install-modes, .deps/.d and .mode files:
@ap_include@


###############################################################################
## Hindi transducer
###############################################################################

$(LANG1).autogen.bin: $(BASENAME).$(LANG1).dix
	lt-comp rl $< $@

$(LANG1).automorf.bin: $(BASENAME).$(LANG1).dix
	lt-comp lr $< $@ $(BASENAME).$(LANG1).acx

$(LANG1).autogen.att.gz: $(LANG1).autogen.bin
	lt-print $< | gzip -9 -c -n > $@

$(LANG1).automorf.att.gz: $(LANG1).automorf.bin
	lt-print $< | gzip -9 -c -n > $@

###############################################################################
## Disambiguation rules 
###############################################################################

$(LANG1).rlx.bin: $(BASENAME).$(LANG1).rlx $(CGCOMP)
	$(CGCOMP) $< $@


###############################################################################
## Spell checker
###############################################################################

$(LANG1).zhfst: .deps/acceptor.default.hfst .deps/errmodel.default.hfst
	rm -f $@
	zip -Z store -j $@ .deps/acceptor.default.hfst .deps/errmodel.default.hfst speller/index.xml

.deps/editdist.default.hfst: speller/editdist.default.txt .deps/acceptor.default.hfst
	python dev/editdist.py -v -s -d 1 -e '@0@' -i $< -a .deps/acceptor.default.hfst >$@.txt
	hfst-txt2fst -i $@.txt -e '@0@' -o $@
	rm -f $@.txt

.deps/editstrings.default.hfst: .deps/strings.default.hfst .deps/editdist.default.hfst
	hfst-disjunct $^ | hfst-minimise | hfst-repeat -f 1 -t 2 -o $@

.deps/errmodel.default.hfst: .deps/words.default.hfst .deps/editstrings.default.hfst
	hfst-disjunct $^ | hfst-fst2fst -f olw -o $@

.deps/words.default.hfst: speller/words.default.txt
	grep -v -e "^#" -e "^$$" $< | hfst-strings2fst -j -o $@

.deps/strings.default.hfst: speller/strings.default.txt .deps/anystar.hfst
	grep -v -e "^#" -e "^$$" $< | hfst-strings2fst -j | hfst-concatenate .deps/anystar.hfst - | hfst-concatenate - .deps/anystar.hfst -o $@

.deps/anystar.hfst:
	echo "?*;" | hfst-regexp2fst -S -o $@

.deps/acceptor.default.hfst: .deps/$(LANG1).autogen.bin 
	lt-print .deps/$(LANG1).autogen.bin | sed 's/ε/@0@/g' | sed 's/ /@_SPACE_@/g' | hfst-txt2fst | hfst-fst2fst -t | hfst-project --project=lower | hfst-minimise |hfst-fst2fst -f olw -o $@ 

.deps/$(LANG1).autogen.bin: .deps/$(BASENAME).$(LANG1).dix
	lt-comp rl $< $@

.deps/$(BASENAME).$(LANG1).dix: $(BASENAME).$(LANG1).dix .deps/.d
	echo '<dictionary>' > $@
	cat $< | xmllint  --xpath './/alphabet|.//sdefs|.//pardefs|.//section[@id="main"]' - >> $@
	echo '</dictionary>' >> $@
	cat .deps/$(BASENAME).$(LANG1).dix | xmllint --encode utf8 - > .deps/$(BASENAME).$(LANG1).dixtmp
	mv .deps/$(BASENAME).$(LANG1).dixtmp $@


###############################################################################
## Distribution
###############################################################################
EXTRA_DIST=$(BASENAME).$(LANG1).dix \
	   $(BASENAME).$(LANG1).rlx  \
	   $(BASENAME).$(LANG1).acx \
	   modes.xml

###############################################################################
## Installation stuff
###############################################################################
#
#   apertium_hin_dir: This is where the compiled binaries go
#   apertium_hin_srcdir: This is where the source files go

apertium_hindir=$(prefix)/share/apertium/$(BASENAME)/
apertium_hin_srcdir=$(prefix)/share/apertium/$(BASENAME)/


EXTRA_TARGETS=

if HAVE_HFSTOSPELL
EXTRA_TARGETS += $(LANG1).zhfst
endif # HAVE_HFSTOSPELL

 
apertium_hin_DATA=$(TARGETS_COMMON) $(EXTRA_TARGETS)

pkgconfigdir = $(prefix)/share/pkgconfig
pkgconfig_DATA = $(BASENAME).pc

# Modes are not installed since they're all just "debug modes". All
# modes are created by this goal.
modes/$(LANG1)-morph.mode: modes.xml
	apertium-validate-modes modes.xml
	apertium-gen-modes modes.xml

noinst_DATA=modes/$(LANG1)-morph.mode

install-data-local: install-modes
	test -d $(DESTDIR)$(apertium_hin_srcdir) || mkdir -p $(DESTDIR)$(apertium_hin_srcdir)
	$(INSTALL_DATA) $(BASENAME).$(LANG1).dix $(DESTDIR)$(apertium_hin_srcdir)
	$(INSTALL_DATA) $(BASENAME).$(LANG1).rlx $(DESTDIR)$(apertium_hin_srcdir)

CLEANFILES = $(TARGETS_COMMON)
clean-local:
	-rm -rf .deps modes
