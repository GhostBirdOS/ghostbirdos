extern	main
extern	io_hlt

global	_start

[section .text]
[bits 32]	

_start:
	call	main
	jmp		io_hlt

[section .data]
