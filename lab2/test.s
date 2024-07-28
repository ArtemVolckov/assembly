section .data

section .text
    global _start
_start:
    mov al, 1
    dec al
    mov bl, 1
    jz end
    mov cx, 1
end:
    mov rax, 60
    syscall
