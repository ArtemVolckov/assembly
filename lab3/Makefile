ASM = nasm
LD = ld

ASMFLAGS = -g -f elf64
LDFLAGS = -static

ASM_SRCS = lab3.s

ASM_OBJS = $(ASM_SRCS:.s=.o)

ASM_EXE = $(ASM_SRCS:.s=)

all: $(ASM_EXE) 

clean:
	rm -f $(ASM_EXE) $(ASM_OBJS)

$(ASM_EXE): $(ASM_OBJS)
	$(LD) $(LDFLAGS) $^ -o $@
	rm -f $^

$(ASM_OBJS): $(ASM_SRCS) 
	$(ASM) $(ASMFLAGS) $^ -o $@
