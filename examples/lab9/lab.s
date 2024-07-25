bits	64
;	Quick sort
section	.data
n:
	dd	10
mas:
	dd	8, 7, 1, 9, 5, 2, 6, 0, 4, 3
section	.text
global	_start
_start:
	mov	edi, mas
	xor	esi, esi
	mov	edx, [n]
	dec	edx
	call	quick
	mov	eax, 60
	mov	edi, 0
	syscall
quick:
	or	esi, esi
	jl	m8
	cmp	esi, edx
	jge	m8
	mov	r8d, esi
	mov	r9d, edx
	mov	eax, [rdi+r8*4]
m1:
	cmp	eax, [rdi+r9*4]
	jg	m3
m2:
	dec	r9d
	cmp	r8d, r9d
	je	m7
	jmp	m1
m3:
	mov	ecx, [rdi+r9*4]
	mov	[rdi+r8*4], ecx
	jmp	m5
m4:
	cmp	eax, [rdi+r8*4]
	jl	m6
m5:
	inc	r8d
	cmp	r8d, r9d
	je	m7
	jmp	m4
m6:
	mov	ecx, [rdi+r8*4]
	mov	[rdi+r9*4], ecx
	jmp	m2
m7:
	mov	[rdi+r9*4], eax
	push	rdi
	push	rdx
	push	r9
	mov	edx, r9d
	dec	edx
	call	quick
	pop	r9
	pop	rdx
	pop	rdi
	mov	esi, r9d
	inc	esi
	call	quick
m8:
	ret
