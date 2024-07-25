bits	64
;	Calculating the determinant of a matrix
section	.data
usage:
	db	"Usage: %s file", 10, 0
mes:
	db	"Determinant equals %f", 10, 0
format:
	db	"Incorrect format of file", 10, 0
size:
	db	"Dimension of matrix must be less or equal 8", 10, 0
formint:
	db	"%d", 0
mode:
	db	"r", 0
section	.text
matrix	equ	512
per	equ	matrix+64
fstring	equ	per+200
prog	equ	fstring+8
file	equ	prog+8
fstruct	equ	file+8
n	equ	fstruct+4
extern	printf
extern	fscanf
extern	fprintf
extern	fopen
extern	fclose
extern	perror
extern	stderr
global	main
main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, n
	and	rsp, -16
	push	rbx
	push	r12
	cmp	rdi, 2
	je	.m1
	mov	rdi, [stderr]
	mov	rdx, [rsi]
	mov	esi, usage
	xor	eax, eax
	call	fprintf
	mov	eax, 1
	jmp	.m19
.m1:
	mov	rax, [rsi]
	mov	[rbp-prog], rax
	mov	rdi, [rsi+8]
	mov	[rbp-file], rdi
	mov	esi, mode
	call	fopen
	or	rax, rax
	jne	.m2
	mov	rdi, [rbp-file]
	call	perror
	mov	eax, 1
	jmp	.m19
.m2:
	mov	[rbp-fstruct], rax
	mov	rdi, rax
	mov	esi, formint
	lea	rdx, [rbp-n]
	xor	eax, eax
	call	fscanf
	cmp	eax, 1
	je	.m4
.m3:
	mov	rdi, [stderr]
	mov	esi, format
	xor	eax, eax
	call	fprintf
	mov	rdi, [rbp-fstruct]
	call	fclose
	mov	eax, 1
	jmp	.m19
.m4:
	mov	eax, [rbp-n]
	cmp	eax, 1
	jl	.m5
	cmp	eax, 8
	jle	.m6
.m5:
	mov	rdi, [stderr]
	mov	esi, size
	xor	eax, eax
	call	fprintf
	mov	rdi, [rbp-fstruct]
	call	fclose
	mov	eax, 1
	jmp	.m19
.m6:
	mul	eax
	lea	rbx, [rbp-fstring]
	mov	ecx, eax
.m7:
	mov	byte [rbx], '%'
	mov	byte [rbx+1], 'l'
	mov	byte [rbx+2], 'f'
	add	rbx, 3
	loop	.m7
	mov	byte [rbx], 0
	mov	ecx, eax
	xor	r12d, r12d
	sub	ecx, 4
	jle	.m11
	lea	rbx, [rbp-matrix+rax*8]
	test	ecx, 1
	jne	.m8
	sub	rbx, 8
	jmp	.m9
.m8:
	inc	ecx
.m9:
	mov	r12d, ecx
	shl	r12d, 3
.m10:
	push	rbx
	sub	rbx, 8
	loop	.m10
.m11:
	mov	rdi, [rbp-fstruct]
	lea	rsi, [rbp-fstring]
	lea	rdx, [rbp-matrix]
	lea	rcx, [rbp-matrix+8]
	lea	r8, [rbp-matrix+16]
	lea	r9, [rbp-matrix+24]
	mov	ebx, eax
	xor	eax, eax
	call	fscanf
	add	rsp, r12
	cmp	eax, ebx
	jne	.m3
	mov	rdi, [rbp-fstruct]
	call	fclose
	xor	ebx, ebx
	mov	ecx, [rbp-n]
.m12:
	mov	[rbp-per+rbx*4], ebx
	inc	ebx
	loop	.m12
	xor	r9d, r9d
	cvtsi2sd	xmm0, r9d
.m13:
	mov	r8d, 1
	mov	r12d, 1
	and	r12d, r9d
	shl	r12d, 1
	sub	r8d, r12d
	cvtsi2sd	xmm1, r8d
	mov	ebx, [rbp-n]
	mov	ecx, ebx
	shl	ebx, 3
	lea	rdi, [rbp-matrix]
	xor	eax, eax
.m14:
	mov	esi, [rbp-per+rax*4]
	mulsd	xmm1, [rdi+rsi*8]
	inc	eax
	add	rdi, rbx
	loop	.m14
	addsd	xmm0, xmm1
	xor	ebx, ebx
	mov	edi, -1
	mov	r8d, -1
	mov	ecx, [rbp-n]
	dec	ecx
	mov	eax, [rbp-per]
.m15:
	mov	edx, [rbp-per+rbx*4+4]
	cmp	eax, edx
	cmovb	edi, ebx
	cmovb	r8d, eax
	inc	ebx
	cmp	edx, r8d
	cmova	esi, ebx
	mov	eax, edx
	loop	.m15
	cmp	edi, -1
	je	.m18
	xchg	r8d, [rbp-per+rsi*4]
	mov	[rbp-per+rdi*4], r8d
	inc	r9d
	mov	ecx, [rbp-n]
	mov	esi, ecx
	sub	ecx, edi
	dec	ecx
	shr	ecx, 1
	jecxz	.m17
	add	r9d, ecx
.m16:
	inc	edi
	dec	esi
	mov	eax, [rbp-per+rdi*4]
	xchg	eax, [rbp-per+rsi*4]
	mov	[rbp-per+rdi*4], eax
	loop	.m16
.m17:
	jmp	.m13
.m18:
	lea	rdi, [mes]
	mov	eax, 1
	call	printf
	xor	eax, eax
.m19:
	pop	r12
	pop	rbx
	leave
	ret
