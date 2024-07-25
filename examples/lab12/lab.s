bits	64
;	Lexicographic word sorting in string
section	.data
size	equ	1024
msg1:
	db	"Enter string: "
msg1len	equ	$-msg1
msg2:
	db	"Result: "
msg2len	equ	$-msg2
delim:
	db	' ', 9, 0
str:
	times size	db	0
newstr:
	times size	db	0
section	.text
global	_start
_start:
	mov	eax, 1
	mov	edi, 1
	mov	esi, msg1
	mov	edx, msg1len
	syscall
	xor	eax, eax
	xor	edi, edi
	mov	esi, str
	mov	edx, size
	syscall
	or	eax, eax
	jl	.m2
	je	.m1
	cmp	eax, size
	je	.m2
	mov	edi, newstr
	mov	esi, str
	mov	edx, delim
	call	work
	mov	eax, 1
	mov	edi, 1
	mov	esi, msg2
	mov	edx, msg2len
	syscall
	mov	eax, 1
	mov	edi, 1
	mov	esi, newstr
	xor	edx, edx
.m0:
	inc	edx
	cmp	byte [rsi+rdx-1], 10
	jne	.m0
	syscall
	jmp	_start
.m1:
	xor	edi, edi
	jmp	.m3
.m2:
	mov	edi, 1
.m3:
	mov	eax, 60
	syscall
sou	equ	8
res	equ	sou+8
del	equ	res+8
w	equ	del+8*size/2
wl	equ	w+4*size/2
n	equ	wl+4
work:
	push	rbp
	mov	rbp, rsp
	sub	rsp, n
	and	rsp, -8
	push	rbx
	mov	[rbp-sou], rsi
	mov	[rbp-res], rdi
	mov	[rbp-del], rdx
	xor	ebx, ebx
	xor	ecx, ecx
.m0:
	mov	al, [rsi]
	inc	rsi
	cmp	al, 10
	je	.m4
	mov	rdi, [rbp-del]
.m1:
	cmp	byte [rdi], 0
	je	.m2
	cmp	byte [rdi], al
	je	.m4
	inc	rdi
	jmp	.m1
.m2:
	or	ebx, ebx
	jne	.m3
	mov	[rbp-w+rcx*8], rsi
	dec	qword [rbp-w+rcx*8]
.m3:
	inc	ebx
	jmp	.m0
.m4:
	or	ebx, ebx
	je	.m5
	mov	[rbp-wl+rcx*4], ebx
	xor	ebx, ebx
	inc	ecx
.m5:
	cmp	al, 10
	jne	.m0
	mov	[rbp-n], ecx
	dec	ecx
	or	ecx, ecx
	je	.m9
	jl	.m13
	xor	edi, edi
.m6:
	inc	edi
	mov	rax, [rbp-w+rdi*8]
	mov	ebx, [rbp-wl+rdi*4]
	mov	esi, edi
.m7:
	dec	esi
	js	.m8
	push	rax
	push	rcx
	push	rdi
	push	rsi
	mov	rdx, [rbp-w+rsi*8]
	mov	ecx, [rbp-wl+rsi*4]
	mov	rdi, rax
	mov	esi, ebx
	call	compare
	or	eax, eax
	pop	rsi
	pop	rdi
	pop	rcx
	pop	rax
	jge	.m8
	mov	r8, [rbp-w+rsi*8]
	mov	[rbp-w+rsi*8+8], r8
	mov	edx, [rbp-wl+rsi*4]
	mov	[rbp-wl+rsi*4+4], edx
	jmp	.m7
.m8:
	inc	esi
	mov	[rbp-w+rsi*8], rax
	mov	[rbp-wl+rsi*4], ebx
	loop	.m6
.m9:
	mov	rdi, [rbp-res]
	mov	ecx, [rbp-n]
	xor	ebx, ebx
.m10:
	push	rcx
	or	ebx, ebx
	je	.m11
	mov	byte [rdi], ' '
	inc	rdi
.m11:
	mov	rsi, [rbp-w+rbx*8]
	mov	ecx, [rbp-wl+rbx*4]
	inc	ebx
.m12:
	mov	al, [rsi]
	mov	[rdi], al
	inc	rsi
	inc	rdi
	loop	.m12
	pop	rcx
	loop	.m10
.m13:
	mov	byte [rdi], 10
	pop	rbx
	leave
	ret
compare:
	or	esi, esi
	jne	.m0
	xor	al, al
	jmp	.m1
.m0:
	mov	al, [rdi]
	inc	rdi
.m1:
	jecxz	.m2
	sub	al, [rdx]
	inc	rdx
	or	al, al
	jne	.m2
	or	esi, esi
	je	.m2
	dec	esi
	dec	ecx
	jmp	compare
.m2:
	cbw
	cwde
	ret
