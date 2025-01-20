all:
	lex calculator.l
	yacc -d calculator.y
	gcc -o calculator.out lex.yy.c y.tab.c
	
clean:
	rm *.yy.c
	rm y.tab.h
	rm y.tab.c
	rm *.out
