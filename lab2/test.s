section .data

section .text
    global _start
_start:
    ;mov rax, 0
    ;mov rbx, 18446744073709551615
    mov al, 126
    mov bl, 255
    sub al, bl
end:
    mov rax, 60
    syscall
