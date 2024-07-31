ASM = nasm
LD = ld

ASMFLAGS = -g -f elf64
LDFLAGS = -static

SRCS = lab2.s
OBJS = $(SRCS:.s=.o)

EXE = $(SRCS:.s=)

SORT_ORDER ?= 1

all: $(EXE) 

clean:
	rm -f $(EXE) 

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@
	rm -f $^

$(OBJS): $(SRCS) 
	$(ASM) $(ASMFLAGS) -D SORT_ORDER=$(SORT_ORDER) $^ -o $@
