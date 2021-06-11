cat apertium-hin.hin.dix | grep '<e lm=' | grep -v '<!--.*<e' | grep -v "i=yes" | wc -l
cat apertium-hin.hin.dix | grep '<e lm=' | grep -v '<!--.*<e' | grep -v "i=yes" | grep -v '__np' | wc -l

