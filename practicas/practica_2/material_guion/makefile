ASM = $(wildcard *.s)
ATT = $(EXE:=.att)
SRC = main.c sum.c
EXE = $(basename  $(ASM)) $(basename $(SRC))

ASFLAGS = -g -no-pie -nostartfiles
CFLAGS = -g -no-pie -Os -Wall

all: att

att: $(ATT)

clean:
	-rm -fv $(ATT) $(EXE) core.* *~

exe: $(EXE)

%.att: %
	objdump -Cd $< > $@

main: mstore.c
sum: msum.c

.PHONY: all att clean exe

