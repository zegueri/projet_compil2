.SUFFIXES: .c .o .gv .png
.PHONY: all clean cleanall

CFLAGS = -Wall -Wextra -g
CLIBS  =

BIN = calc_ast
SRC = parser.tab.c lex.yy.c tree.c main.c
OBJ = $(SRC:.c=.o)

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

.gv.png:
	dot -Tpng $< -o $@

all: $(BIN) parser.png

$(BIN): $(OBJ)
	$(CC) $(CFLAGS) $(CLIBS) -o $(BIN) $(OBJ)

clean:
	rm -fv parser.tab.h parser.tab.c parser.output parser.dot parser.gv lex.yy.c lex.backup *.o *~

cleanall: clean
	rm -fv parser.png $(BIN)

parser.tab.c: parser.y
	bison -d -g -v -t parser.y

lex.yy.c: lexer.l
	flex lexer.l

parser.tab.h: parser.tab.c
parser.gv: parser.tab.c
parser.tab.o: tree.h
lex.yy.o: parser.tab.h
main.o: parser.tab.h tree.h

