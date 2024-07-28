bits 64
;   res=((a*b*c)-(c*d*e))/((a/b)+(c/d))
;   All numbers are unsigned
section	.data
    res        dq  0   
    a          dd  4
    b          dw  2
    c          dd  9
    d          dw  3
    e          dd  10
    isNegative db  0

section	.text

%define SUCCESS 0
%define DIVBYZERO 1
%define OVF 2

; Macro with no arguments
%macro ovf_check 0
    jc ovf_handler
%endmacro
    
    global _start

_start:
    ; Registers set
    mov r8d, dword [a]
    movzx r9, word [b]
    xor r10, r10
    mov r10d, dword [c]
    movzx r11d, word [d]
    mov r12d, dword [e]
    mov r13d, r8d
    xor rax, rax

    ; (a*b*c) -> r8
    mov eax, r8d
    mul r9d
    sal rdx, 32
    or rax, rdx
    mul r10
    ovf_check
    mov r8, rax
    xor rax, rax

    ; (c*d*e) -> r12
    mov eax, r12d
    mul r11d
    sal rdx, 32
    or rax, rdx
    mul r10
    ovf_check
    mov r12, rax

    ; (a/b) -> r9d
    cmp r9w, 0
    je division_by_zero_handler
    mov eax, r13d
    div r9d
    mov r9d, eax

    ; (c/d) -> r10d
    cmp r11w, 0
    je division_by_zero_handler
    mov eax, r10d
    xor edx, edx
    div r11d
    mov r10d, eax

    ; ((a*b*c)-(c*d*e)) -> r8
    sub r8, r12
    ; Here carry flag means that r8 < r12
    jnc endSetNegative
    ; If signed flag is not set that means overflow
    jns ovf_handler

setNegative:
    inc byte [isNegative]
		
endSetNegative:
    ; ((a/b)+(c/d)) -> r9
    add r9, r10
    cmp r9, 0
    je division_by_zero_handler 

    ; ((a*b*c)-(c*d*e))/((a/b)+(c/d)) -> rax
    mov rax, r8
    cmp byte [isNegative], 1
    je signedDivision

unsignedDivision:
    xor rdx, rdx
    div r9
    jmp success

signedDivision:
    cqo
    idiv r9
 
success:
    mov qword [res], rax
    mov edi, SUCCESS    
    jmp exit

division_by_zero_handler:
    mov edi, DIVBYZERO   
    jmp exit

ovf_handler:
    mov edi, OVF   
    jmp exit

exit:
    mov rax, 60         
    syscall
