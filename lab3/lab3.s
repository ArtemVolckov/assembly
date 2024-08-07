bits 64
;   String handling. Deleting words whose last character does not match the last character of the first word
;   Input - standart input (stdin); Output - file
section .data
    err_msg1 db "Usage: "
    err_msg1_len equ $-err_msg1

    err_msg2 db " name_of_environment_variable", 10
    err_msg2_len equ $-err_msg2

    err_msg3 db "Not found env", 10
    err_msg3_len equ $-err_msg3

    err_open db "Can not open the file", 10
    err_open_len equ $-err_open

    err_read db "Can not read from the stdin", 10
    err_read_len equ $-err_read

    err_write db "Can not write in the file", 10
    err_write_len equ $-err_write

    err_close db "Can not close the file", 10
    err_close_len equ $-err_close

    new_line db 10
    space db ' '
    
section .bss
    ; Define buffers for storing characters and lines.
    char_buffer resb 1 
 
    word_buffer resb 16 
    word_buffer_size equ $-word_buffer

    line_buffer resb 64
    line_buffer_size equ $-line_buffer
 
    ; file descriptor
    fd resq 1

    ; boolean variable shows if we found beggining of the first word
    found_first_word resb 1

    ; boolean variable shows if we write first word. Mark for searching a new word
    write_first_word resb 1

    ; boolean variable shows if we found new word. Mark for loading a new word
    found_new_word resb 1
    
section .text

%define ERR_OPEN  1
%define ERR_READ  2
%define ERR_WRITE 3
%define ERR_CLOSE 4

%define ERR_WRONG_FORMAT 5
%define ERR_MISS_ENV     6

    global _start

_start:
    cmp dword [rsp], 2
    jne err_wrong_format

get_1st_arg:
    ; rdi -> name of env
    mov rdi, [rsp+16] 
    mov rbx, 3

get_env:
    ; env array starts with [rsp+32]
    inc rbx
    mov rsi, [rsp+rbx*8]
    ; check if end of array
    or rsi, rsi
    je err_miss_env_end
    xor rcx, rcx

search_mismatch_character:
    mov al, [rdi+rcx]
    cmp al, [rsi+rcx]
    jne check_env
    inc rcx
    jmp search_mismatch_character

check_env:
    ; check if reached end of input env name
    or al, al
    jne get_env

    ; check if reached end of array env name
    cmp byte [rsi+rcx], "="
    jne get_env

    ; rsi -> address of the file name
    lea rsi, [rsi+rcx+1]

open_file:
    mov rax, 2
    mov rdi, rsi
    ; rsi -> 512 | 1 (O_TRUNC & O_WONLY)
    mov rsi, 513
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
    
    ; check read error + EOF
    cmp rax, 0
    jl err_read_end
    je close_file
    
    ; r8 -> counter for line buffer
    xor r8, r8
    dec r8

    cmp byte [found_first_word], 1
    je search_last_symbol

    cmp byte [write_first_word], 1
    je search_new_word

    cmp byte [found_new_word], 1
    je load_new_word
    
search_first_word:
    inc r8
    cmp r8, line_buffer_size
    je read_line
    mov al, byte [line_buffer+r8]

    ; check if space
    cmp al, ' '
    je search_first_word

    ; check if tab
    cmp al, 9
    je search_first_word

    ; check if new line symbol (if true -> write empty line)
    cmp al, 10
    je write_new_line
  
    mov byte [found_first_word], 1 
    ; r10 -> counter for word buffer
    xor r10, r10 
    ; saving first symbol of the first word 
    mov byte [word_buffer], al

search_last_symbol:
    inc r8
    cmp r8, line_buffer_size
    je read_line 
    mov al, byte [line_buffer+r8]

    cmp al, ' '
    je save_last_symbol

    cmp al, 9
    je save_last_symbol

    inc r10
    cmp al, 10
    je write_word
    
    mov byte [word_buffer+r10], al
    jmp search_last_symbol
 
save_last_symbol:
    ; saving last symbol of the first word
    mov al, byte [word_buffer+r10]  
    mov byte [char_buffer], al
    inc r10
    
    mov byte [write_first_word], 1
    mov byte [found_first_word], 0
    jmp write_word
    
search_new_word:
    inc r8
    cmp r8, line_buffer_size
    je read_line 
    mov al, byte [line_buffer+r8]

    cmp al, ' '
    je search_new_word

    cmp al, 9
    je search_new_word

    cmp al, 10
    je write_new_line
    
    mov byte [word_buffer], al
    mov byte [found_new_word], 1
    mov byte [write_first_word], 0

load_new_word:
    inc r8
    cmp r8, line_buffer_size
    je read_line 
    mov al, byte [line_buffer+r8]
    inc r10

    cmp al, ' '
    je check_not_last_word

    cmp al, 9
    je check_not_last_word

    cmp al, 10
    je after_check_not_last_word
    
    mov byte [word_buffer+r10], al
    jmp load_new_word

check_not_last_word:
    mov byte [write_first_word], 1
    mov byte [found_new_word], 0

after_check_not_last_word:
    mov r11, r10
    dec r11
    mov rsi, word_buffer
    add rsi, r11
    mov rdi, char_buffer
    ; comparing bytes
    cmpsb
    je write_space 
    
    xor r10, r10
    cmp byte [write_first_word], 1
    je search_new_word

    jmp write_new_line

write_space:
    ; write into file
    mov rax, 1
    mov rdi, qword [fd]
    mov rsi, space
    mov rdx, 1
    syscall

    ; check write error 
    test rax, rax
    js err_write_end

write_word:
    mov rax, 1
    mov rdi, qword [fd]
    mov rsi, word_buffer
    mov rdx, r10 
    syscall
    
    test rax, rax
    js err_write_end
    
    xor r10, r10
    
    cmp byte [write_first_word], 1
    je search_new_word

write_new_line:
    mov rax, 1
    mov rdi, qword [fd]
    mov rsi, new_line
    mov rdx, 1
    syscall

    test rax, rax
    js err_write_end

    mov byte [found_first_word], 0
    mov byte [write_first_word], 0
    mov byte [found_new_word], 0
    jmp read_line

close_file:
    ; closing file
    mov rax, 3
    mov rdi, qword [fd]
    syscall

    ; check close error
    test rax, rax
    js err_close_end  
    
    mov rdi, 0
    jmp end

err_wrong_format:
    mov rax, 1
    mov rdi, 2
    mov rsi, err_msg1
    mov rdx, err_msg1_len
    syscall

    mov rax, 1
    mov rdi, 2
    mov rsi, [rsp+8]
    xor rdx, rdx

search_file_name_lenght:
    cmp byte [rsi+rdx], 0
    je err_wrong_format_end
    inc rdx
    jmp search_file_name_lenght

err_wrong_format_end:
    syscall
    mov rax, 1
    mov rdi, 2
    mov rsi, err_msg2
    mov rdx, err_msg2_len
    syscall

    mov rdi, ERR_WRONG_FORMAT
    jmp end

err_miss_env_end:
    mov rax, 1
    mov rdi, 2
    mov rsi, err_msg3
    mov rdx, err_msg3_len
    syscall

    mov rdi, ERR_MISS_ENV
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
