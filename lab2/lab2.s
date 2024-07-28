bits 64
; Sorting columns of rectangular matrix by min elements (max 255x255)
; Shaker sort
section .data
    rows    db 1
    columns db 3

    ; align 1

    matrix  db 3,   1,   2   

    min     db 0,   0,   0

    address dq 0,   0,   0

section .text

%define ASCENDING  1
%define DESCENDING 2
    
    global _start

_start:
    mov cl, byte [columns]
    cmp cl, 1
    jbe success
    mov rbx, matrix
    xor dx, dx
row_load:
    xor rdi, rdi
    mov al, byte [rbx]
    push cx
    mov cl, byte [rows]
    dec cl
    cmp cl, 0
    je min_filling
search_min_in_column:
    mov dl, byte [columns]

    ; go to next row
    add di, dx

    mov dl, byte [rbx+rdi]
    cmp al, dl
    cmovg ax, dx 
    loop search_min_in_column
min_filling:    
    mov dl, byte [columns]
    add di, dx
    mov byte [rbx+rdi], al
    inc rbx
    pop cx
    loop row_load
    ; finished filling the min array

    xor rdi, rdi
    mov rbx, matrix
    mov cl, byte [columns]
address_setting:
    mov qword [address+8*rdi], rbx
    inc rdi
    inc rbx
    loop address_setting
shaker_sort:
    xor di, di
    mov rbx, min

    ; r8b -> bool swap
    xor r8b, r8b
    ; r9b -> upper counter
    xor r9b, r9b
    ; r10b -> lower counter
    xor r10b, r10b
    ; r11b -> upper index
    xor r11, r11
    ; r12b -> lower index
    xor r12, r12
    ; r13w -> number of columns
    movzx r13w, byte [columns]
    
    mov cl, r13b
    push cx
    dec cl
upper_iter:
    mov al, byte [rbx+r11]
    mov dl, byte [rbx+r11+1]
    cmp al, dl
    jg upper_swap 
    inc r11b
    loop upper_iter  
after_upper_iter:
    cmp r8b, 0
    je success
    pop cx
    dec cl
    cmp cl, 1
    je success
    push cx
    ; bool swap -> false
    xor r8b, r8b
    ; upper index -> 0
    xor r11b, r11b
    ; upper counter += 1
    inc r9b
    ; lower index -= upper counter
    sub r12b, r9b  
lower_iter:
    mov al, byte [rbx+r12]
    mov dl, byte [rbx+r12-1]
    cmp al, dl
    jl lower_swap
    dec r12b
    loop lower_iter 
after_lower_iter:
    cmp r8b, 0
    je success
    pop cx
    dec cl
    cmp cl, 1
    je success
    push cx
    ; bool swap -> false
    xor r8b, r8b
    mov r12b, byte [columns]
    dec r12b
    inc r10b
    add r11b, r10b
    pop cx
    loop upper_iter
upper_swap:
    ; bool swap -> true
    inc r8b
    ; swap min[r11], min[r11+1]
    mov byte [rbx+r11], dl
    mov byte [rbx+r11+1], al
    ; swap address[r11], address[r11+1]
    mov rbx, address
    mov rax, qword [rbx+r11*8]
    mov rdx, qword [rbx+r11*8+8]
    mov qword [rbx+r11*8], rdx
    mov qword [rbx+r11*8+8], rax
    xor rax, rax
    xor rdx, rdx
    mov rbx, min
    inc r11b
    dec cl
    jnz upper_iter
    jmp after_upper_iter 
lower_swap:
    ; bool swap -> true
    inc r8b
    mov byte [rbx+r12], dl
    mov byte [rbx+r12-1], al
    
    dec r12b
    dec cl
    jnz lower_iter
    jmp after_lower_iter
success:   
    mov rdi, 0 
    mov rax, 60
    syscall
