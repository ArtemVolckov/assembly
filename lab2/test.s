section .text
    global _start
_start:
    cmp rax, 0
    je mark
mark:
    lea rbx, [mark]
    push rbx
    jmp func
some_point:
    mov rdx, 1
func:
    mov rbx, 1
    ret
end:
    mov rax, 60
    syscall
