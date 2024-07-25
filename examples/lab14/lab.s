bits	64
;	Compare exponent from mathlib and my own implementation
section	.data
msg1:
	db	"Input x", 10, 0
msg2:
	db	"%lf", 0
msg3:
	db	"exp(%.10g)=%.10g", 10, 0
msg4:
	db	"myexp(%.10g)=%.10g", 10, 0
section	.text
one	dq	1.0
myexp:
	movsd	xmm1, [one]
	movsd	xmm2, [one]
	movsd	xmm3, [one]
	movsd	xmm4, [one]
.m0:
	movsd	xmm5, xmm2
	mulsd	xmm1, xmm0
	divsd	xmm1, xmm3
	addsd	xmm2, xmm1
	addsd	xmm3, xmm4
	ucomisd	xmm2, xmm5
	jne	.m0
	movsd	xmm0, xmm2
	ret
x	equ	8
y	equ	x+8
extern	printf
extern	scanf
extern	exp
global	main
main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, y
	mov	edi, msg1
	xor	eax, eax
	call	printf
	mov	edi, msg2
	lea	rsi, [rbp-x]
	xor	eax, eax
	call	scanf
	movsd	xmm0, [rbp-x]
	call	exp
	movsd	[rbp-y], xmm0
	mov	edi, msg3
	movsd	xmm0, [rbp-x]
	movsd	xmm1, [rbp-y]
	mov	eax, 2
	call	printf
	movsd	xmm0, [rbp-x]
	call	myexp
	movsd	[rbp-y], xmm0
	mov	edi, msg4
	movsd	xmm0, [rbp-x]
	movsd	xmm1, [rbp-y]
	mov	eax, 2
	call	printf
	leave
	xor	eax, eax
	ret
