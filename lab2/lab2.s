bits 64
; Sorting columns of rectangular matrix by min elements (max matrix size - 255x255)
; Shaker sort
section .data
    rows    db  3
    columns db  4

    ; align 1

    matrix  db  4,  -4,   7, 120
            db -5, -17,   1,  34
            db 22,  15, -67, -10

    min     db  0,   0,   0,   0
    
    align 8

    address dq  matrix, matrix+1, matrix+2, matrix+3

section .text

%define ASCENDING  1
%define DESCENDING 2
    
    global _start

_start:
    movzx rcx, byte [columns]
    cmp cl, 1
    jbe success
    mov rbx, matrix
    xor rdi, rdi
    ; rsi -> number of rows
    mov sil, byte [rows]
    ; r13 -> number of columns
    mov r13w, cx
    ; check SORT_ORDER
    mov rax, SORT_ORDER
    cmp rax, ASCENDING
    je column_load
    cmp rax, DESCENDING
    je column_load
    jmp error
column_load:
    push cx
    mov al, byte [rbx]
    mov cl, sil
    dec cl
    cmp cl, 0
    je min_insert
min_search_loop:
    add di, r13w
    mov dl, byte [rbx+rdi]
    cmp al, dl
    cmovg ax, dx 
    loop min_search_loop
min_insert:    
    add di, r13w
    mov byte [rbx+rdi], al
    inc rbx
    pop cx
    xor di, di
    loop column_load
    ; finished filling the min array

; disabled code. old version -> address = {0} (all zeros)
%if 0 
    xor di, di
    mov rbx, matrix
    mov cl, r13b
address_setting:
    mov qword [address+8*rdi], rbx
    inc dil
    inc rbx
    loop address_setting
%endif

shaker_sort_prepare:
    mov rbx, min
    mov rdi, address
    mov cl, r13b
    dec cl
    push cx

    ; r8 -> bool swap
    xor r8b, r8b
    ; r9 -> upper counter
    mov r9b, cl
    ; r10 -> lower counter
    xor r10b, r10b
    ; r11 -> upper index
    xor r11, r11
    ; r12 -> lower index
    xor r12, r12
    
    mov al, SORT_ORDER
    cmp al, DESCENDING
    je upper_iter_descending 
upper_iter_ascending:
    mov al, byte [rbx+r11]
    mov dl, byte [rbx+r11+1]
    cmp al, dl
    jg upper_swap_ascending 
    inc r11b
    loop upper_iter_ascending  
after_upper_iter_ascending:
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
lower_iter_ascending:
    mov al, byte [rbx+r12]
    mov dl, byte [rbx+r12-1]
    cmp al, dl
    jl lower_swap_ascending
    dec r12b
    loop lower_iter_ascending 
after_lower_iter_ascending:
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
    jmp upper_iter_ascending
upper_swap_ascending:
    ; bool swap -> true
    inc r8b
    ; swap min[r11], min[r11+1]
    mov byte [rbx+r11], dl
    mov byte [rbx+r11+1], al
    ; swap address[r11], address[r11+1]
    mov rax, qword [rdi+r11*8]
    mov rdx, qword [rdi+r11*8+8]
    mov qword [rdi+r11*8], rdx
    mov qword [rdi+r11*8+8], rax
    inc r11b
    dec cl
    jnz upper_iter_ascending
    jmp after_upper_iter_ascending 
lower_swap_ascending:
    ; bool swap -> true
    inc r8b
    ; swap min[r12], min[r12-1]
    mov byte [rbx+r12], dl
    mov byte [rbx+r12-1], al
    ; swap address[r12], address[r12-1]
    mov rax, qword [rdi+r12*8]
    mov rdx, qword [rdi+r12*8-8]
    mov qword [rdi+r12*8], rdx
    mov qword [rdi+r12*8-8], rax
    dec r12b     
    dec cl
    jnz lower_iter_ascending
    jmp after_lower_iter_ascending
upper_iter_descending:
    mov al, byte [rbx+r11]
    mov dl, byte [rbx+r11+1]
    cmp al, dl
    jl upper_swap_descending 
    inc r11b
    loop upper_iter_descending  
after_upper_iter_descending:
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
lower_iter_descending:
    mov al, byte [rbx+r12]
    mov dl, byte [rbx+r12-1]
    cmp al, dl
    jg lower_swap_descending
    dec r12b
    loop lower_iter_descending 
after_lower_iter_descending:
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
    jmp upper_iter_descending
upper_swap_descending:
    ; bool swap -> true
    inc r8b
    ; swap min[r11], min[r11+1]
    mov byte [rbx+r11], dl
    mov byte [rbx+r11+1], al
    ; swap address[r11], address[r11+1]
    mov rax, qword [rdi+r11*8]
    mov rdx, qword [rdi+r11*8+8]
    mov qword [rdi+r11*8], rdx
    mov qword [rdi+r11*8+8], rax
    inc r11b
    dec cl
    jnz upper_iter_descending
    jmp after_upper_iter_descending 
lower_swap_descending:
    ; bool swap -> true
    inc r8b
    ; swap min[r12], min[r12-1]
    mov byte [rbx+r12], dl
    mov byte [rbx+r12-1], al
    ; swap address[r12], address[r12-1]
    mov rax, qword [rdi+r12*8]
    mov rdx, qword [rdi+r12*8-8]
    mov qword [rdi+r12*8], rdx
    mov qword [rdi+r12*8-8], rax
    dec r12b     
    dec cl
    jnz lower_iter_descending
    jmp after_lower_iter_descending
matrix_swap_prepare:
    mov cl, r13b  
    dec cl
    xor r11b, r11b 
    xor r12b, r12b
    mov rbx, matrix
    ; rdi -> address
check_address_match:
    ; if((address[i])==(&matrix+i))
    mov r11, qword [rdi]
    cmp r11, rbx
    jne column_swap 
    inc rbx
    add rdi, 8
    loop check_address_match
    jmp success
column_swap:
    mov al, [rbx+r12]
    mov dl, [r11+r12]
    mov [rbx+r12], dl
    mov [r11+r12], al
    add r12w, r13w
    dec sil
    jnz column_swap
    mov sil, byte [rows]
    push rdi
address_array_update:
    add rdi, 8
    mov r12, qword [rdi]
    cmp rbx, r12
    jne address_array_update
    mov qword [rdi], r11 
    xor r12, r12
    inc rbx
    pop rdi
    add rdi, 8
    loop check_address_match 
success:   
    mov rdi, 0 
    mov rax, 60
    syscall
error:
    mov rdi, 1
    mov rax, 60
    syscall
