bits 64
;   fpu operation
section .data
    msg1 db "Enter x: ", 0
    format db "%d", 0
    number dq 0 

section .bss
    buffer resb 256

section .text
    extern printf
    extern scanf

    global main

main:
    ; read from stdin
   ; push rbp
   ; mov rbp, rsp
   ; sub rsp, 8
    xor rax, rax
    mov rdi, msg1
    call printf
    mov rax, 0
    ret
