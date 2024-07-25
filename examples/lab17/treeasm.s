bits	64
section	.text
b	equ	4
l	equ	8
r	equ	16
rotate:
	mov	r8, l
	mov	r9, r
	or	esi, esi ; -1 - left rotate, 1 - right rotate
	jg	.m0
	xchg	r8, r9
.m0:
	mov	rax, [rdi+r8]
	mov	r10, [rax+r9]
	mov	[rdi+r8], r10
	mov	[rax+r9], rdi
	mov	r8d, [rdi+b]
	mov	r9d, [rax+b]
	add	r8d, esi
	or	r9d, r9d
	je	.m1
	mov	r10d, esi
	xor	r10d, r9d
	jge	.m1
	sub	r8d, r9d
.m1:
	add	r9d, esi
	or	r8d, r8d
	je	.m2
	mov	r10d, esi
	xor	r10d, r8d
	jl	.m2
	add	r9d, r8d
.m2:
	mov	[rdi+b], r8d
	mov	[rax+b], r9d
	ret
extern	malloc
addrecasm:
	cmp	qword [rdi], 0
	jne	.m3
	push	rdi
	push	rsi
	mov	edi, 24
	call	malloc
	pop	rsi
	pop	rdi
	or	rax, rax
	jne	.m1
.m0:
	mov	eax, -1
	ret
.m1:
	mov	[rdi], rax
	mov	[rax], esi
	mov	dword [rax+b], 0
	mov	qword [rax+l], 0
	mov	qword [rax+r], 0
.m2:
	mov	eax, 1
	ret
.m3:
	mov	rcx, [rdi]
	xor	edx, edx
	cmp	esi, [rcx]
	je	.m0
	setg	dl
	shl	edx, 1
	dec	rdx
	push	rdi
	push	rcx
	push	rdx
	lea	rdi, [rcx+12+rdx*4]
	call	addrecasm
	pop	rdx
	pop	rcx
	pop	rdi
	cmp	eax, 1
	je	.m4
	ret
.m4:
	add	[rcx+b], edx
	mov	eax, [rcx+b]
	jne	.m5
	ret
.m5:
	cmp	eax, 1
	je	.m2
	cmp	eax, -1
	je	.m2
	sar	eax, 1
	mov	esi, eax
	mov	edx, l
	or	eax, eax
	jl	.m6
	mov	edx, r
.m6:
	push	rdi
	mov	rdi, [rcx+rdx]
	mov	eax, [rdi+b]
	or	eax, eax
	je	.m7
	xor	eax, esi
	jge	.m7
	call	rotate
	mov	[rcx+rdx], rax
.m7:
	mov	rdi, rcx
	neg	esi
	call	rotate
	pop	rdi
	mov	[rdi], rax
	xor	eax, eax
	ret
global	Addasm
Addasm:
	call	addrecasm
	xor	eax, 0ffffffffh
	je	.m0
	mov	eax, 1
.m0:
	ret
extern	free
delrecasm:
	cmp	qword [rdi], 0
	jne	.m0
	mov	eax, -1
	ret
.m0:
	xor	eax, eax
	mov	rcx, [rdi]
	cmp	esi, [rcx]
	jne	.m1
	mov	rdx, rcx
	cmp	byte [rcx+b], 0
.m1:
	setl	al
	shl	eax, 1
	dec	rax
	push	rax
	push	rdi
	mov	edi, l
	jl	.m2
	mov	edi, r
.m2:
	add	rdi, rcx
	call	delrecasm
	pop	rdi
	cmp	eax, -1
	jne	.m5
	or	rdx, rdx
	jne	.m3
	pop	rcx
	ret
.m3:
	mov	rcx, [rdi]
	cmp	[rcx], esi
	je	.m4
	mov	eax, [rcx]
	mov	[rdx], eax
.m4:
	pop	rax
	mov	eax, [rcx+12+rax*4]
	mov	[rdi], eax
	mov	rdi, rcx
	call	free
	mov	eax, 1
	ret
.m5:
	or	eax, eax
	jne	.m6
	pop	rcx
	ret
.m6:
	pop	rax
	mov	rcx, [rdi]
	add	[rcx+b], eax
	mov	eax, [rcx+b]
	or	eax, eax
	jne	.m8
	mov	eax, 1
	ret
.m7:
	xor	eax, eax
	ret
.m8:
	cmp	eax, 1
	je	.m7
	cmp	eax, -1
	je	.m7
	sar	eax, 1
	movsx	rsi, eax
	push	rdi
	mov	rdi, [rcx+12+rsi*4]
	mov	edx, [rdi+b]
	xor	eax, eax
	or	edx, edx
	sete	al
	push	rax
	je	.m9
	xor	edx, esi
	jge	.m9
	call	rotate
	mov	[rcx+12+rsi*4], rax
.m9:
	pop	rdi
	neg	esi
	push	rdi
	mov	rdi, [rdi]
	call	rotate
	pop	rdi
	mov	[rdi], rax
	pop	rax
	ret
global	Delasm
Delasm:
	xor	rdx, rdx
	call	delrecasm
	xor	eax, 0ffffffffh
	je	.m0
	mov	eax, 1
.m0:
	ret
global	Searchasm
Searchasm:
	mov	rax, rdi
.m0:
	or	rax, rax
	je	.m2
	cmp	esi, [rax]
	je	.m2
	jg	.m1
	mov	rax, [rax+l]
	jmp	.m0
.m1:
	mov	rax, [rax+r]
	jmp	.m0
.m2:
	ret
