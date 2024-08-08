section .text
    global _start

_start:
    mov rax, 5
    cmp rax, 5
    je end
not_end:
    mov rcx, 1
end:
    mov rax, 60
    mov rdi, 0
    syscall
