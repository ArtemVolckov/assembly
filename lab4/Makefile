ASM = nasm
LD = ld

ASMFLAGS = -g -f elf64
LDFLAGS = -static -z noexecstack

LIBPATH = -L /lib/gcc/x86_64-linux-gnu/13
OBJPATH = /usr/lib/x86_64-linux-gnu

LIBS = -lgcc -lgcc_eh -lc -lm

PREOBJ = $(OBJPATH)/crt1.o $(OBJPATH)/crti.o
POSTOBJ = $(OBJPATH)/crtn.o

ASM_SRCS = lab4.s

ASM_OBJS = $(ASM_SRCS:.s=.o)

ASM_EXE = $(ASM_SRCS:.s=)

all: $(ASM_EXE) 

clean:
		rm -f $(ASM_EXE) $(ASM_OBJS)

$(ASM_EXE): $(ASM_OBJS)
		$(LD) $(LDFLAGS) $(LIBPATH) $(PREOBJ) $^ $(POSTOBJ) -\( $(LIBS) -\) -o $@
		rm -f $^

$(ASM_OBJS): $(ASM_SRCS) 
		$(ASM) $(ASMFLAGS) $^ -o $@
