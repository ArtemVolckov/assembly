bits 64
;	res=((a*b*c)-(c*d*e))/((a/b)+(c/d))
section	.data
res 
    dq	0
a:
	dd	2
b:
	dw	2
c:
	dd	1
d:
	dw	1
e:
	dd  1
isNegative:
	db  0

global _start

section	.text

%define SUCCESS 0
%define DIVBYZERO 1
%define OVF 2

%define SIGFPE 8
    extern signal

; Macro with no arguments
%macro ovf_check 0
	jo ovf_handler
%endmacro

_start:
    ; Div by zero handler set
    sub rsp, 8   
    lea	rax, [rel div_by_zero_handler]
	mov rsi, rax
	mov edi, SIGFPE
	;call signal WRT ..plt
	add rsp, 8

	xor r8, r8
	mov r8d, [a]
	xor r9, r9
	mov r9w, [b]
	xor r10, r10
	mov r10d, [c]
	xor r11, r11
	mov r11w, [d]
	xor r12, r12
	mov r12d, [e]
	mov r13, r8
	mov r14, r13

    ; (a*b*c) -> r8
	mov eax, r8d
    mul r9
	ovf_check
	mul r10
	ovf_check
	mov r8, rax
	xor rax, rax

	; (c*d*e) -> r12
	mov eax, r12d
	mul r11
	ovf_check
	mul r10
	ovf_check
	mov r12, rax
	xor rax, rax

	; (a/b) -> r9
	mov eax, r13d
	div r9d
	mov r9d, eax

	; (c/d) -> r10
	mov eax, r10d
	div r11d
	mov r10d, eax

	; ((a*b*c)-(c*d*e)) -> r8
	sub r8, r12
	ovf_check
	jns endSetNegative

setNegative:
	mov byte [isNegative], 1
		
endSetNegative:
	; ((a/b)+(c/d)) -> r9
	add r9d, r10d
	ovf_check

	; ((a*b*c)-(c*d*e))/((a/b)+(c/d))
	mov rax, r8
	cmp byte [isNegative], 1
	je signedUnsignedDivision

unsignedDivision:
	div r9
	jmp success

signedUnsignedDivision:
	neg rax
	div r9
	neg rax
    
success:
	mov [res], rax
	mov edi, SUCCESS    
	jmp exit

div_by_zero_handler:
	mov edi, DIVBYZERO   
	jmp exit

ovf_handler:
	mov edi, OVF   
	jmp exit

exit:
	mov rax, 60         
	syscall
