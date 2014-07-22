	.file	"memory.c"
	.comm	pdt,4,4
	.comm	pt,4,4
	.comm	mem_map,4,4
	.comm	k_mem_map,4,4
	.text
	.globl	inti_memory
	.type	inti_memory, @function
inti_memory:
.LFB0:
	pushl	%ebp
.LCFI0:
	movl	%esp, %ebp
.LCFI1:
	subl	$40, %esp
.LCFI2:
	movl	$196608, mem_map
	movl	$327680, k_mem_map
	movl	$0, -12(%ebp)
	jmp	.L2
.L5:
	movl	k_mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%eax, %edx
	movl	mem_map, %eax
	movl	-12(%ebp), %ecx
	sall	$3, %ecx
	addl	%ecx, %eax
	movl	(%eax), %eax
	movl	%eax, (%edx)
	movl	mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	4(%eax), %eax
	cmpl	$268435455, %eax
	jbe	.L3
	movl	k_mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	$268435456, 4(%eax)
	jmp	.L4
.L3:
	movl	k_mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%eax, %edx
	movl	mem_map, %eax
	movl	-12(%ebp), %ecx
	sall	$3, %ecx
	addl	%ecx, %eax
	movl	4(%eax), %eax
	movl	%eax, 4(%edx)
.L4:
	addl	$1, -12(%ebp)
.L2:
	movl	mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	4(%eax), %eax
	testl	%eax, %eax
	jne	.L5
	movl	$0, -12(%ebp)
	jmp	.L6
.L9:
	movl	mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	4(%eax), %eax
	cmpl	$268435456, %eax
	ja	.L7
	movl	mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	$0, (%eax)
	movl	mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	$0, 4(%eax)
	jmp	.L8
.L7:
	movl	mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	$268435456, (%eax)
.L8:
	addl	$1, -12(%ebp)
.L6:
	movl	mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	(%eax), %eax
	cmpl	$268435456, %eax
	setbe	%cl
	movl	mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	(%eax), %eax
	testl	%eax, %eax
	setne	%al
	andl	%ecx, %eax
	testb	%al, %al
	jne	.L9
	movl	$4096, (%esp)
	call	kmalloc
	movl	%eax, pdt
	movl	$4194304, (%esp)
	call	kmalloc
	movl	%eax, pt
	movl	$0, -12(%ebp)
	jmp	.L10
.L11:
	movl	pdt, %eax
	movl	-12(%ebp), %edx
	sall	$2, %edx
	addl	%eax, %edx
	movl	-12(%ebp), %eax
	movl	%eax, %ecx
	sall	$12, %ecx
	movl	pt, %eax
	addl	%ecx, %eax
	addl	$259, %eax
	movl	%eax, (%edx)
	addl	$1, -12(%ebp)
.L10:
	cmpl	$1023, -12(%ebp)
	jbe	.L11
	movl	$0, -12(%ebp)
	jmp	.L12
.L13:
	movl	pt, %eax
	movl	-12(%ebp), %edx
	sall	$2, %edx
	addl	%eax, %edx
	movl	-12(%ebp), %eax
	sall	$12, %eax
	addl	$259, %eax
	movl	%eax, (%edx)
	addl	$1, -12(%ebp)
.L12:
	cmpl	$1048575, -12(%ebp)
	jbe	.L13
	movl	pdt, %eax
	movl	%eax, (%esp)
	call	goto_paging
	leave
.LCFI3:
	ret
.LFE0:
	.size	inti_memory, .-inti_memory
	.section	.rodata
.LC0:
	.string	"kmalloc is error!"
	.text
	.globl	kmalloc
	.type	kmalloc, @function
kmalloc:
.LFB1:
	pushl	%ebp
.LCFI4:
	movl	%esp, %ebp
.LCFI5:
	subl	$40, %esp
.LCFI6:
	movl	8(%ebp), %eax
	andl	$4095, %eax
	testl	%eax, %eax
	je	.L15
	movl	8(%ebp), %eax
	andl	$-4096, %eax
	addl	$4096, %eax
	movl	%eax, 8(%ebp)
.L15:
	movl	$0, -12(%ebp)
	jmp	.L16
.L20:
	movl	k_mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	4(%eax), %edx
	movl	k_mem_map, %eax
	movl	-12(%ebp), %ecx
	sall	$3, %ecx
	addl	%ecx, %eax
	movl	(%eax), %eax
	movl	%edx, %ecx
	subl	%eax, %ecx
	movl	%ecx, %eax
	cmpl	8(%ebp), %eax
	jne	.L17
	movl	k_mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	(%eax), %eax
	movl	%eax, -16(%ebp)
	movl	k_mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	$0, (%eax)
	movl	k_mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	$0, 4(%eax)
	movl	-16(%ebp), %eax
	jmp	.L18
.L17:
	movl	k_mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	4(%eax), %edx
	movl	k_mem_map, %eax
	movl	-12(%ebp), %ecx
	sall	$3, %ecx
	addl	%ecx, %eax
	movl	(%eax), %eax
	movl	%edx, %ecx
	subl	%eax, %ecx
	movl	%ecx, %eax
	cmpl	8(%ebp), %eax
	jbe	.L19
	movl	k_mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%edx, %eax
	movl	(%eax), %eax
	movl	%eax, -16(%ebp)
	movl	k_mem_map, %eax
	movl	-12(%ebp), %edx
	sall	$3, %edx
	addl	%eax, %edx
	movl	k_mem_map, %eax
	movl	-12(%ebp), %ecx
	sall	$3, %ecx
	addl	%ecx, %eax
	movl	(%eax), %eax
	addl	8(%ebp), %eax
	movl	%eax, (%edx)
	movl	-16(%ebp), %eax
	jmp	.L18
.L19:
	addl	$1, -12(%ebp)
.L16:
	cmpl	$8191, -12(%ebp)
	jle	.L20
	movl	$.LC0, (%esp)
	call	printk
	call	io_hlt
	jmp	.L14
.L18:
.L14:
	leave
.LCFI7:
	ret
.LFE1:
	.size	kmalloc, .-kmalloc
	.globl	kfree
	.type	kfree, @function
kfree:
.LFB2:
	pushl	%ebp
.LCFI8:
	movl	%esp, %ebp
.LCFI9:
	popl	%ebp
.LCFI10:
	ret
.LFE2:
	.size	kfree, .-kfree
	.globl	vremap
	.type	vremap, @function
vremap:
.LFB3:
	pushl	%ebp
.LCFI11:
	movl	%esp, %ebp
.LCFI12:
	movl	8(%ebp), %eax
	andl	$4095, %eax
	testl	%eax, %eax
	je	.L23
	movl	$1, %eax
	jmp	.L24
.L23:
	movl	12(%ebp), %eax
	andl	$4095, %eax
	testl	%eax, %eax
	je	.L25
	movl	$2, %eax
	jmp	.L24
.L25:
	movl	16(%ebp), %eax
	andl	$4095, %eax
	testl	%eax, %eax
	je	.L27
	movl	$3, %eax
	jmp	.L24
.L28:
	movl	pt, %eax
	movl	8(%ebp), %edx
	shrl	$12, %edx
	sall	$2, %edx
	addl	%eax, %edx
	movl	12(%ebp), %eax
	addl	$259, %eax
	movl	%eax, (%edx)
	addl	$4096, 12(%ebp)
	addl	$4096, 8(%ebp)
	subl	$4096, 16(%ebp)
.L27:
	cmpl	$0, 16(%ebp)
	jne	.L28
	movl	$0, %eax
.L24:
	popl	%ebp
.LCFI13:
	ret
.LFE3:
	.size	vremap, .-vremap
	.globl	kmemcpy
	.type	kmemcpy, @function
kmemcpy:
.LFB4:
	pushl	%ebp
.LCFI14:
	movl	%esp, %ebp
.LCFI15:
	subl	$16, %esp
.LCFI16:
	movl	$0, -4(%ebp)
	jmp	.L30
.L31:
	movl	-4(%ebp), %eax
	addl	12(%ebp), %eax
	movl	-4(%ebp), %edx
	addl	8(%ebp), %edx
	movzbl	(%edx), %edx
	movb	%dl, (%eax)
	addl	$1, -4(%ebp)
.L30:
	movl	-4(%ebp), %eax
	cmpl	16(%ebp), %eax
	jb	.L31
	leave
.LCFI17:
	ret
.LFE4:
	.size	kmemcpy, .-kmemcpy
	.section	.eh_frame,"aw",@progbits
.Lframe1:
	.long	.LECIE1-.LSCIE1
.LSCIE1:
	.long	0
	.byte	0x1
	.string	""
	.byte	0x1
	.byte	0x7c
	.byte	0x8
	.byte	0xc
	.byte	0x4
	.byte	0x4
	.byte	0x88
	.byte	0x1
	.align 4
.LECIE1:
.LSFDE1:
	.long	.LEFDE1-.LASFDE1
.LASFDE1:
	.long	.LASFDE1-.Lframe1
	.long	.LFB0
	.long	.LFE0-.LFB0
	.byte	0x4
	.long	.LCFI0-.LFB0
	.byte	0xe
	.byte	0x8
	.byte	0x85
	.byte	0x2
	.byte	0x4
	.long	.LCFI1-.LCFI0
	.byte	0xd
	.byte	0x5
	.byte	0x4
	.long	.LCFI3-.LCFI1
	.byte	0xc5
	.byte	0xc
	.byte	0x4
	.byte	0x4
	.align 4
.LEFDE1:
.LSFDE3:
	.long	.LEFDE3-.LASFDE3
.LASFDE3:
	.long	.LASFDE3-.Lframe1
	.long	.LFB1
	.long	.LFE1-.LFB1
	.byte	0x4
	.long	.LCFI4-.LFB1
	.byte	0xe
	.byte	0x8
	.byte	0x85
	.byte	0x2
	.byte	0x4
	.long	.LCFI5-.LCFI4
	.byte	0xd
	.byte	0x5
	.byte	0x4
	.long	.LCFI7-.LCFI5
	.byte	0xc5
	.byte	0xc
	.byte	0x4
	.byte	0x4
	.align 4
.LEFDE3:
.LSFDE5:
	.long	.LEFDE5-.LASFDE5
.LASFDE5:
	.long	.LASFDE5-.Lframe1
	.long	.LFB2
	.long	.LFE2-.LFB2
	.byte	0x4
	.long	.LCFI8-.LFB2
	.byte	0xe
	.byte	0x8
	.byte	0x85
	.byte	0x2
	.byte	0x4
	.long	.LCFI9-.LCFI8
	.byte	0xd
	.byte	0x5
	.byte	0x4
	.long	.LCFI10-.LCFI9
	.byte	0xc
	.byte	0x4
	.byte	0x4
	.byte	0xc5
	.align 4
.LEFDE5:
.LSFDE7:
	.long	.LEFDE7-.LASFDE7
.LASFDE7:
	.long	.LASFDE7-.Lframe1
	.long	.LFB3
	.long	.LFE3-.LFB3
	.byte	0x4
	.long	.LCFI11-.LFB3
	.byte	0xe
	.byte	0x8
	.byte	0x85
	.byte	0x2
	.byte	0x4
	.long	.LCFI12-.LCFI11
	.byte	0xd
	.byte	0x5
	.byte	0x4
	.long	.LCFI13-.LCFI12
	.byte	0xc
	.byte	0x4
	.byte	0x4
	.byte	0xc5
	.align 4
.LEFDE7:
.LSFDE9:
	.long	.LEFDE9-.LASFDE9
.LASFDE9:
	.long	.LASFDE9-.Lframe1
	.long	.LFB4
	.long	.LFE4-.LFB4
	.byte	0x4
	.long	.LCFI14-.LFB4
	.byte	0xe
	.byte	0x8
	.byte	0x85
	.byte	0x2
	.byte	0x4
	.long	.LCFI15-.LCFI14
	.byte	0xd
	.byte	0x5
	.byte	0x4
	.long	.LCFI17-.LCFI15
	.byte	0xc5
	.byte	0xc
	.byte	0x4
	.byte	0x4
	.align 4
.LEFDE9:
	.ident	"GCC: (GNU) 4.6.1"
