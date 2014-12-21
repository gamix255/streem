YACC = bison -y
LEX = flex
TARGET = bin/streem
JSTARGET = bin/streem.js

TESTS=$(wildcard example/*.strm)

all : $(TARGET)
js : $(JSTARGET)

.PHONY : all

test : all
	$(TARGET) $(TESTS)

.PHONY : test

src/y.tab.c : src/parse.y
	$(YACC) -o src/y.tab.c src/parse.y

src/lex.yy.c : src/lex.l
	$(LEX) -o src/lex.yy.c src/lex.l

src/parse.o : src/y.tab.c src/lex.yy.c
	$(CC) -g -c src/y.tab.c -o src/parse.o

src/parse-js.o : src/y.tab.c src/lex.yy.c
	$(EMCC) -g -c src/y.tab.c -o src/parse-js.o

$(TARGET) : src/parse.o
	mkdir -p "$$(dirname $(TARGET))"
	$(CC) -g src/parse.o -o $(TARGET)

src/streem-body.js : src/parse-js.o
	$(EMCC) -g src/parse-js.o -o src/streem-body.js

$(JSTARGET) : src/streem-body.js
	mkdir -p "$$(dirname $(TARGET))"
	cat src/header.js src/streem-body.js src/footer.js > $(JSTARGET)

clean :
	rm -f src/y.output src/y.tab.c
	rm -f src/lex.yy.c
	rm -f src/streem-body.js
	rm -f src/*.o $(TARGET).*
.PHONY : clean
