bits 64
;   String handling. Deleting words whose last character does not match the last character of the first word
;   Input - standart input (stdin); Output - file
section .data
    err_open db "Can not open the file", 10
    err_open_len equ $-err_open

    err_read db "Can not read from the stdin", 10
    err_read_len equ $-err_read

    err_write db "Can not write in the file", 10
    err_write_len equ $-err_write

    err_close db "Can not close the file", 10
    err_close_len equ $-err_close
    
section .bss
    ; Define buffers for storing characters and lines.
    char_buffer resb 1 

    word_buffer resb 16 
    word_buffer_size equ $-word_buffer

    line_buffer resb 64
    line_buffer_size equ $-line_buffer

    ; file descriptor
    fd  resq  1
    
    ; boolean variable if there is a word in the string
    is_word  resb  1

    ; boolean variable if there is end of a string
    is_end  resb  1

section .text

%define ERR_OPEN  1
%define ERR_READ  2
%define ERR_WRITE 3
%define ERR_CLOSE 4

    global _start

_start:
    ; open file
    mov rax, 2
    mov rdi, [rsp+16]
    ; rsi -> write only
    mov rsi, 1
    ; rdx -> file flags (if new file)
    xor rdx, rdx
    syscall

    ; check open error
    test rax, rax
    js err_open_end

    ; save fd
    mov qword [fd], rax 

read_line:
    ; read from stdin
    mov rax, 0
    mov rdi, 0
    mov rsi, line_buffer
    mov rdx, line_buffer_size 
    syscall
    
    ; check read error 
    test rax, rax
    js err_read_end
    
    ; r8 -> counter
    xor r8, r8
    dec r8
    
search_first_word:
    inc r8
    cmp r8, line_buffer_size
    je m2

    ; check if space
    cmp byte [line_buffer+r8], ' '
    je search_first_word

    ; check if tab
    cmp byte [line_buffer+r8], 9
    je search_first_word

    ; check if new line symbol
    cmp byte [line_buffer+r8], 10
    je m3
    
    mov byte [is_word], 1

m2:
    cmp byte [is_word], 0
    je read_line

    jmp end
 
    mov rcx, line_buffer_size

    ; write into file
    mov rax, 1
    mov rdi, qword [fd]
    mov rsi, line_buffer
    mov rdx, line_buffer_size
    syscall

    ; check write error 
    test rax, rax
    js err_write_end

file_close:
    ; close file
    mov rax, 3
    mov rdi, qword [fd]
    syscall

    ; check close error
    test rax, rax
    js err_close_end  
    
    mov rdi, 0
    jmp end
   
err_open_end:
    mov rax, 1
    mov rdi, 2
    mov rsi, err_open
    mov rdx, err_open_len
    syscall
    mov rdi, ERR_OPEN
    jmp end

err_read_end:
    mov rax, 1
    mov rdi, 2
    mov rsi, err_read
    mov rdx, err_read_len
    syscall
    mov rdi, ERR_READ
    jmp end

err_write_end:
    mov rax, 1
    mov rdi, 2
    mov rsi, err_write
    mov rdx, err_write_len
    syscall
    mov rdi, ERR_WRITE
    jmp end

err_close_end:
    mov rax, 1
    mov rdi, 2
    mov rsi, err_close
    mov rdx, err_close_len
    syscall
    mov rdi, ERR_CLOSE

end:
    mov rax, 60
    syscall
