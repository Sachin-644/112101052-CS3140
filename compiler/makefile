all: src/compiler.l src/compiler.y
	mkdir -p bin
	flex -o bin/lex.yy.c src/compiler.l
	bison -d -o bin/compiler.tab.c src/compiler.y
	gcc bin/lex.yy.c bin/compiler.tab.c -ll -o bin/compiler
clean:
	rm -rf bin