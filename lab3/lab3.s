bits 64
; String handling. Deleting words whose last character does not match the last character of the first word
; Input - standart input (stdin); Output - file
section .data

%define W_ONLY, 1
    
section .bss
    ; Define buffers for storing characters and lines.
    char_buffer resb 1 
    word_buffer resb 16 
    line_buffer resb 64

    word_buffer_size equ $-word_buffer
    line_buffer_size equ $-line_buffer

section .text
    global _start

_start:
    ; file open
    mov rax, 2
    mov rdi, [rsp+16]
    ; rsi -> write only
    mov rsi, 1
    ; rdx -> file flags (if new file)
    mov rdx, 0
    syscall

    ; read from stdin
    mov rax, 0
    mov rdi, 0
    mov rsi, line_buffer
    mov rdx, line_buffer_size 
    syscall
    
    ; write into file

    ; file close
    mov rax, 3
   
success:
    mov edi, 0
    mov rax, 60
    syscall
error:
    mov edi, 1
    mov rax, 60
    syscall
    
