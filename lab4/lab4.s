bits 64 
;   fpu operation
section .rodata
    err_msg1 db "Usage: ", 0

    err_msg2 db " file_name", 10, 0

    err_open db "Can not open the file", 10, 0
 
    err_close db "Can not close the file", 10, 0

    err_read1 db "Error. Wrong input format", 10, 0
    err_read2 db "Error. |x| > 1", 10, 0
    err_read3 db "Error. accuracy <= 0", 10, 0

    err_write db "Can not write in the file", 10, 0

    new_line db 10

    msg1 db "Enter x (|x| <= 1): ", 0
    msg2 db "Enter accuracy (accuracy > 0): ", 0

    fopen_mode db "w", 0 
    
    scanf_format db "%lf", 0

    one dq 1.0
    minus_one dq -1.0

section .bss
    x resq 1
    accuracy resq 1 

    fd resq 1

section .text

%define SUCCESS   0
%define ERR_OPEN  1
%define ERR_CLOSE 2
%define ERR_READ  3
%define ERR_WRITE 4

%define ERR_WRONG_FORMAT 5
%define ERR_MISS_FILE    6

    extern printf, fprintf, scanf
    extern fflush
    extern fopen, fclose
    extern stdin, stderr
    
    global main

main:
    ; rdi -> argc; rsi -> argv
    push rbp
    mov rbp, rsp
    cmp rdi, 2
    jne err_wrong_format_end

open_file:
    lea rdi, [rsi+8]
    mov rdi, [rdi]
    mov rsi, fopen_mode
    call fopen

    ; check open error
    cmp rax, 0
    je err_open_end
    mov qword [fd], rax

get_x_and_accuracy:
    mov rdi, msg1
    call printf

    ; get x
    mov rsi, x
    mov rdi, scanf_format
    call scanf
    
    cmp rax, 1
    jne err_input_end

    ; check if x > 1
    movsd xmm0, qword [x]
    ucomisd xmm0, qword [one]
    ja err_input_x_end

    ; check if x < -1
    ucomisd xmm0, qword [minus_one]
    jb err_input_x_end
    
    mov rdi, [stdin]
    call fflush

    mov rdi, msg2
    call printf 

    ; get accuracy
    mov rsi, accuracy
    mov rdi, scanf_format
    call scanf

    cmp rax, 1
    jne err_input_end

    ; check if accuracy <= 0
    mov rax, qword [accuracy]
    test rax, rax
    js err_input_accuracy_end

    cmp rax, 0
    je err_input_accuracy_end

close_file:
    mov rdi, qword [fd]
    call fclose

    ; check close error
    cmp rax, 0
    jne err_close_end
    mov rax, SUCCESS
    jmp end

err_wrong_format_end:
    push rsi
    mov rdi, [stderr]
    mov rsi, err_msg1
    xor rax, rax
    call fprintf

    mov rdi, [stderr]
    pop rsi
    mov rsi, [rsi]
    xor rax, rax
    call fprintf

    mov rdi, [stderr]
    mov rsi, err_msg2
    xor rax, rax
    call fprintf

    mov rax, ERR_WRONG_FORMAT
    jmp end

err_open_end:
    mov rdi, [stderr]
    mov rsi, err_open
    call fprintf

    mov rax, ERR_OPEN
    jmp end

err_input_end:
    mov rdi, [stderr]
    mov rsi, err_read1
    xor rax, rax
    call fprintf

    mov rax, ERR_READ
    jmp end

err_input_x_end:
    mov rdi, [stderr]
    mov rsi, err_read2
    xor rax, rax
    call fprintf

    mov rax, ERR_READ
    jmp end

err_input_accuracy_end:
    mov rdi, [stderr]
    mov rsi, err_read3
    xor rax, rax
    call fprintf

    mov rax, ERR_READ
    jmp end

err_close_end:
    mov rdi, [stderr]
    mov rsi, err_close
    xor rax, rax
    call fprintf

    mov rax, ERR_CLOSE

end:
    leave
    ret
