bits	64
;	Heap sort
section	.data
n:
	dd	10
mas:
	dd	8, 7, 1, 9, 5, 2, 6, 0, 4, 3
section	.text
global	_start
_start:
	mov	ebx, mas
	mov	esi, [n]
	mov	edi, esi
	dec	edi
	jle	m8
	shr	esi, 1
m1:
	or	esi, esi
	jnz	m2
	cmp	edi, 1
	jz	m7
	mov	eax, [rbx]
	xchg	eax, [rbx+rdi*4]
	mov	[rbx], eax
	dec	edi
	jmp	m3
m2:
	dec	esi
m3:
	mov	eax, [rbx+rsi*4]
	push	rsi
	mov	ecx, esi
m4:
	shl	ecx, 1
	inc	ecx
	cmp	ecx, edi
	je	m5
	jg	m6
	mov	edx, [rbx+rcx*4]
	cmp	edx, [rbx+rcx*4+4]
	jge	m5
	inc	ecx
m5:
	cmp	eax, [rbx+rcx*4]
	jge	m6
	mov	edx, [rbx+rcx*4]
	mov	[rbx+rsi*4], edx
	mov	esi, ecx
	jmp	m4
m6:
	mov	[rbx+rsi*4], eax
	pop	rsi
	jmp	m1
m7:
	mov	eax, [rbx]
	cmp	eax, [rbx+4]
	jle	m8
	xchg	eax, [rbx+4]
	mov	[rbx], eax
m8:
	mov	eax, 60
	mov	edi, 0
	syscall
