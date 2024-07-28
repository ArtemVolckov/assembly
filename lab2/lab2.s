bits 64
; Sorting columns of rectangular matrix by min elements (max matrix size - 255x255)
; Shaker sort
section .data
    rows    db 1
    columns db 4

    ; align 1

    matrix  db 4,   3,   2,   1  

    min     db 0,   0,   0,   0
    
    align 8

    address dq 0,   0,   0,   0

section .text

%define ASCENDING  1
%define DESCENDING 2
    
    global _start

_start:
    movzx rcx, byte [columns]
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

    ; go to the next row
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

    xor di, di
    mov rbx, matrix
    mov cl, byte [columns]
address_setting:
    mov qword [address+8*rdi], rbx
    inc dil
    inc rbx
    loop address_setting
shaker_sort_prepart:
    ; TODO
    xor dil, dil
    mov rbx, min
    mov cl, byte [columns] 
    dec cl
    push cx

    ; r8b -> bool swap
    xor r8b, r8b
    ; r9b -> upper counter
    mov r9b, cl
    ; r10b -> lower counter
    xor r10b, r10b
    ; r11 -> upper index
    xor r11, r11
    ; r12 -> lower index
    xor r12, r12
    
upper_iter:
    mov al, byte [rbx+r11]
    mov dl, byte [rbx+r11+1]
    cmp al, dl
    jg upper_swap 
    inc r11b
    loop upper_iter  
after_upper_iter:
    cmp r8b, 0
    je matrix_swap_prepare
    pop cx
    dec cl
    cmp cl, 0
    je matrix_swap_prepare
    push cx
    ; bool swap -> false
    xor r8b, r8b
    ; upper counter -= 1
    dec r9b
    ; lower index = upper counter
    mov r12b, r9b
lower_iter:
    mov al, byte [rbx+r12]
    mov dl, byte [rbx+r12-1]
    cmp al, dl
    jl lower_swap
    dec r12b
    loop lower_iter 
after_lower_iter:
    cmp r8b, 0
    je matrix_swap_prepare
    pop cx
    dec cl
    cmp cl, 0
    je matrix_swap_prepare
    push cx
    ; bool swap -> false
    xor r8b, r8b
    ; lower counter += 1
    inc r10b
    ; upper index = lower counter
    mov r11b, r10b 
    jmp upper_iter
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
    ; swap min[r12], min[r12-1]
    mov byte [rbx+r12], dl
    mov byte [rbx+r12-1], al
    ; swap address[r12], address[r12-1]
    mov rbx, address
    mov rax, qword [rbx+r12*8]
    mov rdx, qword [rbx+r12*8-8]
    xor rax, rax
    xor rdx, rdx
    mov rbx, min
    dec r12b     
    dec cl
    jnz lower_iter
    jmp after_lower_iter
matrix_swap_prepare:
    mov cl, byte [columns]  
    dec cl
    ; r8 -> source address
    mov r8, matrix
    ; r9 -> destination address
    mov r9, qword [address]
    ; r10 -> qword [address]
    mov r10, r9
    ; r11b -> number of rows
    mov r11b, byte [rows]
    ; r12b -> number of columns
    mov r12b, byte [columns]
check_address_match:
    cmp r8, r9
    jne address_search_prepare 
    inc r8
    add r9, 8
    loop check_address_match
    jmp success
address_search_prepare:
    push cx
    mov cl, byte [columns] 
address_search:
    cmp r8, r10
    je column_swap_loop
    add r10, 8
    loop address_search
column_swap_loop:
    
     
    mov r10, qword [address] 
    pop cx
    cmp cx, 1
    je success
    jmp check_address_match     
success:   
    mov rdi, 0 
    mov rax, 60
    syscall
