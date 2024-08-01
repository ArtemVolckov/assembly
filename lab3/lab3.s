bits 64
; String handling. Deleting words whose last character does not match the last character of the first word
; Input - standart input (stdin); Output - file
section .data
    
section .bss
    ; Define buffers for storing characters and lines.
    filename_buffer resb 16
    char_buffer resb 1 
    word_buffer resb 16 
    line_buffer resb 64

%define filename_sz 16
%define lnbuf_sz 64
%define wordbuf_sz 16
    
section .text
    global _start

_start:
    
success:
    mov edi, 0
    mov rax, 60
    syscall
error:
    mov edi, 1
    mov rax, 60
    syscall
    
