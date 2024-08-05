ASM = nasm
LD = ld
CC = gcc

ASMFLAGS = -g -f elf64
LDFLAGS = -static

ASM_SRCS = lab1.s
C_SRCS = main.c

ASM_OBJS = $(ASM_SRCS:.s=.o)

ASM_EXE = $(ASM_SRCS:.s=)
C_EXE = $(C_SRCS:.c=)

all: $(ASM_EXE) $(C_EXE)

clean:
	rm -f $(ASM_EXE) $(C_EXE) $(ASM_OBJS)

$(ASM_EXE): $(ASM_OBJS)
	$(LD) $(LDFLAGS) $^ -o $@
	rm -f $^

$(ASM_OBJS): $(ASM_SRCS) 
	$(ASM) $(ASMFLAGS) $^ -o $@

$(C_EXE): $(C_SRCS)
	$(CC) $^ -o $@
