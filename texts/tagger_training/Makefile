SRC=001.tagged.txt 

all: hin.unigram.prob

hin.unigram.prob: hin.tagged.txt
	apertium-tagger -d -s 0 -u 2 $@ $<

hin.tagged.txt: $(SRC)
	cat $(SRC) > $@

%.tagged.txt: %.vislcg.txt
	grep -v '^;' $< | cg-conv -A -l | sed "s/\$\^/$\\n^/g" | sed 's/¶/\n/g' | grep -v '\*' > $@

clean: 
	rm *.tagged.txt *.prob
