CC=gcc
LEX=flex
YACC=bison
CFLAGS=-Wall -g -Isrc -I.

all: logic_interpreter

parser.tab.c parser.tab.h: src/parser.y
	$(YACC) -d -v $< -o parser.tab.c

lex.yy.c: src/lexer.l parser.tab.h
	$(LEX) -o lex.yy.c $<

logic_interpreter: lex.yy.c parser.tab.c src/main.c src/logic.c
	$(CC) $(CFLAGS) -o $@ lex.yy.c parser.tab.c src/main.c src/logic.c

clean:
	rm -f logic_interpreter lex.yy.c parser.tab.c parser.tab.h parser.output