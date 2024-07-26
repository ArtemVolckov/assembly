bits 64
; Sorting columns of rectangular matrix by min elements (max 255x255)
; Shaker sort
section .data
    rows    db 4
    columns db 4

    matrix  db 1,   2,   3,   4,
               5,   6,   7,   8,
               9,   10,  11,  12,
               13,  14,  15,  16

section .text

%define ASCENDING  1
%define DESCENDING 2
    
    global _start

_start:
    mov cl, [columns]
    cmp cl, 1
    jle m8
    mov bl, matrix 
m1:
        

m8:    
    mov rax, 60
    syscall
