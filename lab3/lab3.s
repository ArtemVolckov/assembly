bits 64
; String handling. Deleting words whose last character does not match the last character of the first word
; Input - standart input (stdin); Output - file
section .data
    err_msg_1  db  "Can not open the file"
    err_msg_1_len equ $-err_msg_1
    
section .bss
    ; Define buffers for storing characters and lines.
    char_buffer resb 1 

    word_buffer resb 16 
    word_buffer_size equ $-word_buffer

    line_buffer resb 64
    line_buffer_size equ $-line_buffer

section .text
    global _start

_start:
    ; open file
    mov rax, 2
    mov rdi, [rsp+16]
    ; rsi -> write only
    mov rsi, 1
    ; rdx -> file flags (if new file)
    xor rdx, rdx
    syscall

    ; open error check
    test rax, rax
    js err_msg_1_print

    ; read from stdin
    mov rax, 0
    mov rdi, 0
    mov rsi, line_buffer
    mov rdx, line_buffer_size 
    syscall
    
    ; write into file

    ; close file
    mov rax, 3
   
success:
    mov edi, 0
    mov rax, 60
    syscall
err_msg_1_print:
    mov rax, 1
    mov rdi, 2
    mov rsi, err_msg_1
    mov rdx, err_msg_1_len
    syscall 
error:
    mov rdi, 1
    mov rax, 60
    syscall
    
