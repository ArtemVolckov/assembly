section .bss
    line_buffer resb 16      ; резервируем 128 байт для буфера
    line_buffer_size equ 16   ; размер буфера
    total_length resd 1        ; общее количество прочитанных байт

section .text
    global _start

_start:
    ; Инициализация
    mov dword [total_length], 0

read_loop:
    ; Считываем данные
    mov rax, 0                ; syscall номер для sys_read (0)
    mov rdi, 0                ; дескриптор файла 0 - stdin
    mov rsi, line_buffer      ; адрес буфера
    mov rdx, line_buffer_size  ; размер буфера
    syscall

    ; Проверяем, сколько байт было прочитано
    cmp rax, 0                ; проверяем, достигнут ли конец ввода (0 байт)
    je done                    ; если да, переходим к завершению

    ; Обновляем общее количество прочитанных байт
    add dword [total_length], eax

    ; Если прочитано меньше, чем размер буфера, добавляем нулевой байт
    cmp rax, line_buffer_size
    jl add_null               ; если прочитано меньше, добавляем конец строки

    ; В противном случае продолжаем чтение
    jmp read_loop

add_null:
    ; Добавляем нулевой байт в конец считанной строки
    mov eax, [total_length]   ; общее количество прочитанных байт
    mov byte [line_buffer + eax], 0  ; добавляем символ конца строки

done:
    ; Здесь можно использовать line_buffer по вашему усмотрению,
    ; например, вывести его на экран

    ; Вызов sys_write для вывода на экран
    mov rax, 1                ; syscall номер для sys_write (1)
    mov rdi, 1                ; дескриптор файла 1 - stdout
    mov rsi, line_buffer      ; адрес буфера
    mov rdx, [total_length]   ; количество байт для записи
    syscall

    ; Завершение программы
    mov rax, 60               ; syscall номер для sys_exit
    xor rdi, rdi              ; код возврата 0
    syscall
