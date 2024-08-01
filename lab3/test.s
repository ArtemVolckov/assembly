global _start
 
section .text
_start:
    ; находим количество символов в строке
    mov rdi, [rsp+8]    ; получим в RDI адрес пути к файлу, который применялся при вызове
    xor rax, rax        ; AL равен 0
    mov rcx, -1         ; помещаем очень большое число
    repne scasb           ; ищем нулевой байт
    ; в rdi - адрес следующего за нулем символа
    mov byte [rdi-1], 10   ; заменяем нулевой байт переводом строки
    sub rdi, [rsp+8]        ; получаем длину строки включая нулевой символ -  RDI-[rsp+8]           
 
 
    ; вывод на строки на экран
    mov rdx, rdi
    mov rdi, 1
    mov rsi, [rsp+8]
    mov rax, 1
    syscall
 
    mov rax, 60
    syscall
