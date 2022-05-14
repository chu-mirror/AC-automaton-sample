CFLAGS = -g
OBJ = AC-automaton poj1625
SRC = ${OBJ:=.c}

.SUFFIXES: .w .tex .pdf
.w.c:
	ctangle $<
.w.tex:
	cweave $<
.tex.pdf:
	pdftex $<

all: ${OBJ} AC-automaton.pdf

clean:
	rm -f ${OBJ} ${SRC} \
		AC-automaton.c AC-automaton.scn AC-automaton.pdf AC-automaton.toc \
		AC-automaton.log AC-automaton.idx

