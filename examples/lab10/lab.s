bits	64
;	Revers symbols in words
section	.data
size	equ	1024
msg1:
	db	"Enter string: "
msg1len	equ	$-msg1
str:
	times size	db	0
msg2:
	db	"Result: '"
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
	jl	m6
	je	m5
	cmp	eax, size
	je	m6
	mov	esi, str
	mov	edi, newstr
	cmp	byte [rsi+rax-1], 10
	jne	m6
	xor	ecx, ecx
m0:
	mov	al, [rsi]
	inc	esi
	cmp	al, 10
	je	m1
	cmp	al, ' '
	je	m1
	cmp	al, 9
	je	m1
	inc	ecx
	jmp	m0
m1:
	jecxz	m4
	cmp	edi, newstr
	je	m2
	mov	byte [rdi], ' '
	inc	edi
m2:
	mov	edx, esi
	dec	edx
m3:
	dec	edx
	mov	bl, [rdx]
	mov	[rdi], bl
	inc	edi
	loop	m3
m4:
	cmp	al, 10
	jne	m0
	mov	word [rdi], 2560+"'"
	inc	edi
	inc	edi
	mov	eax, 1
	mov	esi, msg2
	mov	edx, edi
	sub	edx, msg2
	mov	edi, 1
	syscall
	jmp	_start
m5:
	xor	edi, edi
	jmp	m7
m6:
	mov	edi, 1
m7:
	mov	eax, 60
	syscall
