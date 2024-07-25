ASM = nasm
LD = ld

ASMFLAGS = -g -f elf64
LDFLAGS = -static

SRCS = lab1.s
OBJS = $(SRCS:.s=.o)

EXE = $(SRCS:.s=)

all: $(EXE) $(OBJS)

clean:
	rm -f $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@

$(OBJS): $(SRCS) 
	$(ASM) $(ASMFLAGS) $^ -o $@
