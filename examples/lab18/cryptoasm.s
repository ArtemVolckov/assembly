bits	64
%ifdef	SSE
global	cryptoasmSSE
%else
global	cryptoasm
%endif
extern	fprintf
extern	printf
extern	fopen
extern	fread
extern	fwrite
extern	fclose
extern	perror
buf	equ	4096
fin	equ	buf+8
fout	equ	fin+8
filef	equ	fout+8
filet	equ	filef+8
key	equ	filet+8
section	.data
r:
	db	"r", 0
w:
	db	"w", 0
section	.text
%ifdef	SSE
cryptoasmSSE:
%else
cryptoasm:
%endif
	push	rbp
	mov	rbp, rsp
	sub	rsp, key
	and	rsp, -16
	push	rbx
	mov	[rbp-filef], rdi
	mov	[rbp-filet], rsi
	mov	[rbp-key], rdx
	mov	rsi, r
	call	fopen
	or	rax, rax
	jne	.m1
	mov	rdi, [rbp-filef]
	call	perror
	mov	eax, 1
	jmp	.m7
.m1:
	mov	[rbp-fin], rax
	mov	rdi, [rbp-filet]
	mov	rsi, w
	call	fopen
	or	rax, rax
	jne	.m2
	mov	rdi, [rbp-filet]
	call	perror
	mov	rdi, [rbp-fin]
	call	fclose
	mov	eax, 1
	jmp	.m7
.m2:
	mov	[rbp-fout], rax
.m3:
	lea	rdi, [rbp-buf]
	mov	esi, 1
	mov	edx, buf
	mov	rcx, [rbp-fin]
	call	fread
	or	eax, eax
	jle	.m7
	mov	ebx, eax
	xor	edx, edx
%ifdef	SSE
	mov	ecx, 16
%else
	mov	ecx, 8
%endif
	div	ecx
	mov	ecx, eax
	jecxz	.m5
	lea	rdi, [rbp-buf]
%ifdef	SSE
	movhps	xmm0, [rbp-key]
	movlps	xmm0, [rbp-key]
%else
	mov	rax, [rbp-key]
%endif
.m4:
%ifdef	SSE
	movaps	xmm1, xmm0
	pxor	xmm1, [rdi]
	movaps	[rdi], xmm1
	add	rdi, 16
%else
	xor	[rdi], rax
	add	rdi, 8
%endif
	loop	.m4
.m5:
	or	edx, edx
	je	.m6
%ifdef	SSE
	movaps	xmm1, xmm0
	pxor	xmm1, [rdi]
	movaps	[rdi], xmm1
%else
	xor	[rdi], rax
%endif
.m6:
	lea	rdi, [rbp-buf]
	mov	esi, 1
	mov	edx, ebx
	mov	rcx, [rbp-fout]
	call	fwrite
	cmp	ebx, eax
	je	.m3
.m7:
	mov	ebx, eax
	mov	rdi, [rbp-fin]
	call	fclose
	mov	rdi, [rbp-fout]
	call	fclose
	mov	eax, ebx
	pop	rbx
	leave
	ret
