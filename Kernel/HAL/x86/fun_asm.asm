;Copyright 2013-2014 by 2013-2014 by Explorer OS Developer. All rights reserved.

;Explorer 0.01 x86平台硬件抽象层
;File name:Explorer\Kernel\HAL\x86\fun_asm.asm
;2014.7.14 1:03 PM

%include	"include/address.asm"

;全局函数

;GDT操作函数
global	clean_GDT
global	creat_GDT
global	write_GDTR
;控制寄存器读写
global	read_CR0,write_CR0
global	read_CR3,write_CR3
;输入输出函数
global	io_hlt,io_cli,io_sti
global	io_read_eflags,io_write_eflags
global	io_in8,io_in16,io_in32
global	io_out8,io_out16,io_out32
;特殊大小内存读写函数
global	write_mem24

;调用宏
;int creat_GDT(int segment_base, int limit, int attribute)
%macro call_creat_GDT 3
	push	dword %3
	push	dword %2
	push	dword %1
	call	creat_GDT
%endmacro
	code_32	equ	0x401A00
	data_32	equ	0x401200
	DPL_0	equ	00000000_00000000b
	P		equ	10000000_00000000b
	G		equ	0x800000
	
;代码区
[section .text]
[bits 32]
;Warning:能自由使用的寄存器只有EAX\ECX\EDX
;GDT操作
clean_GDT:
;void clean_GDT(void)
	mov		edx,[GDT_base]
	mov		ecx,GDT_size
	shr		ecx,2
.loop:
	mov		dword[edx],0x0
	add		edx,4
	loop	.loop
	ret
creat_GDT:
;int creat(int segment_base, int limit, int attribute)
	push	ebp
	mov		ebp,esp
	push	esi
	;表基地址
	mov		esi,[GDT_base]
.loop:
	;跳过空描述符以及循环查找功能
	add		esi,8
	;判断该GDT表项是否是8字节的0
	cmp		dword[esi],0x00
	jnz		.loop
	cmp		dword[esi+4],0x00
	jnz		.loop
	;将段基址放置到GDT中
	mov		eax,[ebp+8]
	mov		[esi+2],ax
	shr		eax,16
	mov		[esi+4],al
	mov		[esi+7],ah
	;将界限放置到GDT
	mov		eax,[ebp+12]
	mov		[esi],ax
	;震荡eax,保证高12位为0
	shl		eax,12
	shr		eax,12+16
	mov		[esi+6],al
	;将属性加入表项中
	mov		eax,[ebp+16]
	add		[esi+4],eax
	;计算出select value
	mov		eax,esi
	sub		eax,[GDT_base]
	pop		esi
	pop		ebp
	ret		12
write_GDTR:
	ret
	
;控制寄存器的读写
read_CR0:
	mov		eax,cr0
	ret
read_CR3:
	mov		eax,cr3
	ret
write_CR0:
	mov		eax,[esp+4]
	mov		cr0,eax
	ret
write_CR3:
	mov		eax,[esp+4]
	mov		cr3,eax
	ret

;输入输出函数
io_hlt:
	hlt
	ret
io_cli:
	cli
	ret
io_sti:
	sti
	ret
io_read_eflags:
	pushfd
	pop		eax
	ret
io_write_eflags:
	mov		eax,[esp+4]
	push	eax
	popfd
	ret
io_in8:
	mov		edx,[esp+4]
	xor		eax,eax
	in		al,dx
	ret
io_in16:
	mov		edx,[esp+4]
	xor		eax,eax
	in		ax,dx
	ret
io_in32:
	mov		edx,[esp+4]
	in		eax,dx
	ret
io_out8:
	mov		edx,[esp+4]
	mov		al,[esp+8]
	out		dx,al
	ret
io_out16:
	mov		edx,[esp+4]
	mov		eax,[esp+8]
	out		dx,ax
	ret
io_out32:
	mov		edx,[esp+4]
	mov		eax,[esp+8]
	out		dx,eax
	ret
	
write_mem24:
	mov		edx,[esp+8]
	mov		ecx,[esp+4]
	mov		[ecx],dx
	shr		dx,16
	mov		[ecx+2],dl
	ret
	
;数据区
[section .data]
;GDTR
GDT_size		dw	65535			;GDT的长度
GDT_base		dd	GDT_addr		;GDT的物理地址
