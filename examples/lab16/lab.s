bits	64
;	Integral of the exponent by the Simpson's method
section	.data
msg1:
	db	"Input x1", 10, 0
msg2:
	db	"Input x2", 10, 0
msg3:
	db	"Incorrect doudle value", 10, 0
msg4:
	db	"x1 should be less than x2", 10, 0
msg5:
	db	"Input n", 10, 0
msg6:
	db	"Incorrect integer value", 10, 0
msg7:
	db	"n should be from 1 to 100", 10, 0
form1:
	db	"%lf", 0
form2:
	db	"%d", 0
form3:
	db	"%*[^", 10, "]", 0
form4:
	db	"Exact integral equals %.10g", 10, 0
form5:
	db	"My integral equals %.10g", 10, 0
section	.text
x1	equ	8
x2	equ	x1+8
y	equ	x2+8
step	equ	y+8
n	equ	step+4
extern	printf
extern	scanf
extern	exp
global	main
main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, n
	and	rsp, -16
.m1:
	mov	edi, msg1
	xor	eax, eax
	call	printf
	mov	edi, form1
	lea	rsi, [rbp-x1]
	xor	eax, eax
	call	scanf
	cmp	eax, 1
	je	.m2
	or	eax, eax
	jne	.m11
	mov	edi, form3
	xor	eax, eax
	call	scanf
	mov	edi, msg3
	xor	eax, eax
	call	printf
	jmp	.m1
.m2:
	mov	edi, msg2
	xor	eax, eax
	call	printf
	mov	edi, form1
	lea	rsi, [rbp-x2]
	xor	eax, eax
	call	scanf
	cmp	eax, 1
	je	.m3
	or	eax, eax
	jne	.m11
	mov	edi, form3
	xor	eax, eax
	call	scanf
	mov	edi, msg3
	xor	eax, eax
	call	printf
	jmp	.m2
.m3:
	movsd	xmm0, [rbp-x1]
	ucomisd	xmm0, [rbp-x2]
	jb	.m4
	mov	edi, msg4
	xor	eax, eax
	call	printf
	jmp	.m1
.m4:
	mov	edi, msg5
	xor	eax, eax
	call	printf
	mov	edi, form2
	lea	rsi, [rbp-n]
	xor	eax, eax
	call	scanf
	cmp	eax, 1
	je	.m6
	or	eax, eax
	jne	.m11
	mov	edi, form3
	xor	eax, eax
	call	scanf
	mov	edi, msg6
	xor	eax, eax
	call	printf
	jmp	.m4
.m6:
	mov	eax, [rbp-n]
	or	eax, eax
	jle	.m7
	cmp	eax, 100
	jle	.m8
.m7:
	mov	edi, msg7
	xor	eax, eax
	call	printf
	mov	eax, 1
	jmp	.m4
.m8:
	movsd	xmm0, [rbp-x1]
	call	exp
	movsd	[rbp-y], xmm0
	movsd	xmm0, [rbp-x2]
	call	exp
	subsd	xmm0, [rbp-y]
	mov	edi, form4
	mov	eax, 1
	call	printf
	xor	eax, eax
	and	dword [rbp-n], -2
	mov	ecx, [rbp-n]
	movsd	xmm0,[rbp-x2]
	subsd	xmm0, [rbp-x1]
	cvtsi2sd	xmm1, ecx
	divsd	xmm0, xmm1
	movsd	[rbp-step], xmm0
	dec	ecx
.m9:
	movsd	xmm0, [rbp-x1]
	addsd	xmm0, [rbp-step]
	movsd	[rbp-x1], xmm0
	mov	[rbp-n], ecx
	call	exp
	mov	ecx, [rbp-n]
	test	ecx, 1
	je	.m10
	addsd	xmm0, xmm0
.m10:
	addsd	xmm0, xmm0
	addsd	xmm0, [rbp-y]
	movsd	[rbp-y], xmm0
	loop	.m9
	movsd	xmm0, [rbp-x1]
	addsd	xmm0, [rbp-step]
	call	exp
	addsd	xmm0, [rbp-y]
	mulsd	xmm0, [rbp-step]
	mov	eax, 3
	cvtsi2sd	xmm1, eax
	divsd	xmm0, xmm1
	mov	edi, form5
	mov	eax, 1
	call	printf
	xor	eax, eax
.m11:
	leave
	ret
