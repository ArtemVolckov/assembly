bits 64 
;   fpu operation
;   natural logarithm calculating 
section .rodata
    err_msg1 db "Usage: ", 0

    err_msg2 db " file_name", 10, 0

    err_open db "Can not open the file", 10, 0
 
    err_close db "Can not close the file", 10, 0

    err_read1 db "Error. Wrong input format", 10, 0
    err_read2 db "Error. |x| > 1", 10, 0
    err_read3 db "Error. accuracy <= 0", 10, 0

    err_write db "Can not write in the file", 10, 0

    msg1 db "Enter x (|x| <= 1): ", 0
    msg2 db "Enter accuracy (accuracy > 0): ", 0

    msg3 db 10, "ln(x + sqrt(x^2 + 1))", 10, 0
    msg4 db "left: ", 0
    msg5 db "right: ", 0
    
    new_line db 10, 0
    space db ' ', 0

    fopen_mode db "w", 0 
    
    double_format_scanf db "%lf", 0
    double_format db "%.15lf", 0
    int_format db "%d", 0

    one dq 1.0
    minus_one dq -1.0
    two dq 2.0
    three dq 3.0

section .bss
    x resq 1
    accuracy resq 1

    save_xmm8 resq 1
    save_xmm9 resq 1 
    save_xmm10 resq 1
    save_xmm11 resq 1

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
    extern log, pow, fabs
    
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
    mov rdi, double_format_scanf
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
    mov rdi, double_format_scanf
    call scanf

    cmp rax, 1
    jne err_input_end

    ; check if accuracy <= 0
    mov rax, qword [accuracy]
    test rax, rax
    js err_input_accuracy_end

    cmp rax, 0
    je err_input_accuracy_end

logarifm_calculating:
    mov rdi, msg3
    call printf

    mov rdi, msg4
    call printf
    ; a subroutine for calculating the natural logarithm directly
    call logarifm_left

    mov rdi, msg5
    call printf
    ; a subroutine for calculating the natural logarithm using a series
    call logarifm_right

close_file:
    mov rdi, qword [fd]
    call fclose

    ; check close error
    cmp rax, 0
    jne err_close_end
    mov rax, SUCCESS
    jmp end

logarifm_left:
    push rbp
    mov rbp, rsp
   
    ; xmm0 -> x^2
    movsd xmm0, qword [x]
    mulsd xmm0, xmm0
    ; xmm0 -> x^2 + 1
    addsd xmm0, qword [one]
    ; xmm0 -> sqrt(x^2 + 1) 
    sqrtsd xmm0, xmm0
    ; xmm0 -> x + sqrt(x^2 + 1)
    addsd xmm0, qword [x]
    ; xmm0 -> ln(x + sqrt(x^2 + 1)) 
    call log

    mov rdi, double_format
    call printf

    mov rdi, new_line
    call printf 
    
    leave
    ret

logarifm_right:
    push rbp
    mov rbp, rsp

    ; r12 -> counter
    mov r12, 1
    ; xmm8 -> sum
    movsd xmm8, qword [x]
    ; xmm9 -> 2n + 1
    movsd xmm9, qword [three]
    ; xmm10 -> (2n)!!
    movsd xmm10, qword [two]
    ; xmm11 -> (2n - 1)!!
    movsd xmm11, qword [one] 

get_and_print_series_member:
    ; print member number
    mov rdi, qword [fd] 
    mov rsi, int_format
    mov rdx, r12
    xor rax, rax
    call fprintf

    ; print space
    mov rdi, qword [fd]
    mov rsi, space
    xor rax, rax
    call fprintf

    ; x^(2n + 1)
    movsd xmm0, qword [x]
    movsd xmm1, xmm9
    movsd qword [save_xmm8], xmm8
    movsd qword [save_xmm9], xmm9
    movsd qword [save_xmm10], xmm10
    movsd qword [save_xmm11], xmm11
    call pow

    ; (x^(2n + 1))/(2n + 1)
    movsd xmm9, qword [save_xmm9]
    divsd xmm0, xmm9

    ; ((x^(2n + 1))/(2n + 1))*((2n − 1)!!)
    movsd xmm11, qword [save_xmm11]
    mulsd xmm0, xmm11

    ; (((x^(2n + 1))/(2n + 1))*((2n − 1)!!))/((2n)!!)
    movsd xmm10, qword [save_xmm10]
    divsd xmm0, xmm10

    ; xmm12 -> save xmm0
    movsd xmm12, xmm0

    test r12, 1
    jz after_odd 

odd:
    ; ((((x^(2n + 1))/(2n + 1))*((2n − 1)!!))/((2n)!!))*(-1)
    mulsd xmm0, qword [minus_one]

after_odd:
    movsd xmm8, qword [save_xmm8]
    addsd xmm8, xmm0
    
    ; print member; rax -> 1 (number of variables with floating point)
    mov rdi, qword [fd]
    mov rsi, double_format
    mov rax, 1
    call fprintf

    movsd xmm0, xmm12
    call fabs

    ucomisd xmm0, qword [accuracy]
    jb end_logarifm_right
    
    ; printf new line symbol
    mov rdi, qword [fd]
    mov rsi, new_line
    xor rax, rax
    call fprintf

    inc r12
    addsd xmm9, qword [two]
    
    cvtsi2sd xmm0, r12
    mulsd xmm0, qword [two]
    mulsd xmm10, xmm0

    cvtsi2sd xmm0, r12
    mulsd xmm0, qword [two]
    subsd xmm0, qword [one]
    mulsd xmm11, xmm0 

    jmp get_and_print_series_member    

end_logarifm_right:
    movsd xmm0, xmm8
    mov rdi, double_format
    call printf

    mov rdi, new_line
    call printf 
    
    leave
    ret

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
