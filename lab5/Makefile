AS = nasm
CC = gcc -Ofast

CC_FLAGS = -no-pie
AS_FLAGS = -f elf64

MAIN_SRC = lab5.c
GRAYSCALE_C_SRC = convert_to_grayscale_c.c
GRAYSCALE_S_SRC = convert_to_grayscale_s.s

GRAYSCALE_C_OBJ = $(GRAYSCALE_C_SRC:.c=.o)
GRAYSCALE_S_OBJ = $(GRAYSCALE_S_SRC:.s=.o)

EXE = $(MAIN_SRC:.c=)

all: $(EXE)

clean:
	rm -f $(EXE) $(MAIN_OBJ) $(GRAYSCALE_C_OBJ) $(GRAYSCALE_S_OBJ)

$(EXE): $(GRAYSCALE_S_OBJ) $(GRAYSCALE_C_OBJ)
	$(CC) $(CC_FLAGS) $(MAIN_SRC) $(GRAYSCALE_C_OBJ) $(GRAYSCALE_S_OBJ) -o $@ -lm
	rm -f $(GRAYSCALE_C_OBJ) $(GRAYSCALE_S_OBJ)
		
$(GRAYSCALE_C_OBJ): $(GRAYSCALE_C_SRC)
	$(CC) $(CC_FLAGS) -c $< -o $@

$(GRAYSCALE_S_OBJ): $(GRAYSCALE_S_SRC)
	$(AS) $(AS_FLAGS) $< -o $@
