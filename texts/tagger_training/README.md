# Steps

* First convert the raw file to a vislcg format file using:

```
cat text_file.raw.txt | apertium -d ../../ hin-disam > text_file.vislcg.txt
```

* Then edit the file `text_file.vislcg.txt` and fix the tokenisation, disambiguate it and add
missing analyses

## Training

### To train the unigram tagger

* The file must not contain any unknown words, otherwise you will get the following 
error:

```
apertium-tagger: can't train LexicalUnit comprising empty Analysis std::vector
Try 'apertium-tagger --help' for more information.
```

### Tips:

* analyse foreign works as 'barb' (barbarism)

