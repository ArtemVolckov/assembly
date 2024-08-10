bits 64
section .data
    red_multiplier   dq 0.3
    green_multiplier dq 0.59
    blue_multiplier  dq 0.11

section .text
    global convert_to_grayscale_s

; rdi - image pointer (unsigned char*)
; rsi - width (int)
; rdx - height (int)
; rcx - channels (int)

convert_to_grayscale_s:
    push rbp
    mov rbp, rsp
    push rbx
    ; r11 -> channels
    mov r11, rcx
    ; r10 -> a number of pixels
    mov r10, rsi
    imul r10, rdx
    ; r9 -> img offset
    mov r9, rdi
    ; r8 -> i
    mov r8, 0

loop:
    cmp r8, r10
    jge done

    ; al -> img[idx]     (R)
    movzx eax, byte [r9]
    ; bl -> img[idx + 1] (G)
    movzx ebx, byte [r9 + 1]
    ; cl -> img[idx + 2] (B)
    movzx ecx, byte [r9 + 2]

    cvtsi2sd xmm0, eax
    cvtsi2sd xmm1, ebx
    cvtsi2sd xmm2, ecx

    ; al -> gray = 0.3 * R + 0.59 * G + 0.11 * B
    mulsd xmm0, qword [red_multiplier]
    mulsd xmm1, qword [green_multiplier]
    mulsd xmm2, qword [blue_multiplier]
    
    addsd xmm0, xmm1
    addsd xmm0, xmm2

    cvtsd2si eax, xmm0

    mov byte [r9], al
    mov byte [r9 + 1], al
    mov byte [r9 + 2], al

loop_continue:
    inc r8
    add r9, r11
    jmp loop

done:
    pop rbx
    leave
    ret

section .note.GNU-stack
