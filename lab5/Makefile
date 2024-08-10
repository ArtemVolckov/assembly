AS = nasm
LD = ld
CC = gcc

C_FLAGS = -g

LIBS = -lm

MAIN_C_SRC = lab5.c

EXE = $(MAIN_C_SRC:.c=)

all: $(EXE)

$(EXE): $(MAIN_C_SRC)
	$(CC) $^ -o $@ $(LIBS)
