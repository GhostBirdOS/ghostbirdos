;(C)copyright 鬼鸟实验室 2014
;(C)copyright 2014 Ghost Bird Laboratory 
;任何人和组织可以随便使用此源代码，使用应遵照当地法律法规。
;Any person or organization can easily use this source code, should be in accordance with local laws and regulations.
;内存分布
;0x0~0x7bff			堆栈段
;0x7c00~0xbfff		初始化代码段
;0x100000~0x3fffff	背景图层段
;0x400000~0x6fffff	test窗口图层段
;0x700000~0x9fffff	;鼠标图层段
org	0x7c00
read_FDD:		;读取软盘17个扇区
	xor		ax,ax
	mov		es,ax
	mov		bx,0x7e00
	mov		ah,0x02
	mov		al,17
	mov		ch,0x00
	mov		cl,0x02
	mov		dh,0x00
	mov		dl,0x00
	int		13h
check_memory:
	mov		ax,cs
	mov		es,ax
	mov		di,ards
	mov		eax,0xe820
	xor		ebx,ebx
	mov		ecx,20
	mov		edx,0534D4150h
	int		15h
	mov		eax,0xe820
	int		15h
	jmp		loader
	ards:	times	20	db	0
times	510-($-$$)	db	0
dw		0xaa55
loader:
;初始化图形显示模式
inti_display:
	
	mov		ax,0x4F02
	mov		bx,0x4118
	int		0x10
	mov		word[scrx],1024
	mov		word[scry],768
	mov		dword[vram],0xe0000000

;在此编写实模式代码
	protect_mode:
		lgdt	[cs: gdt_size]
		lidt	[cs: idt_size]
		in		al,0x92
		or		al,0000_0010B
		out		0x92,al
		cli
		mov		eax,cr0
		or		eax,1
		mov		cr0,eax
		jmp		0x08:inti
		gdt:
			;在此安装描述符
		
			;0描述符
			dd	0x00000000
			dd	0x00000000
			;1描述符(代码段描述符)
			dd	0x0000ffff
			dd	0x00cf9A00
			;2描述符(文本模式显存描述符)
			dd	0x8000ffff
			dd	0x0040920b
			;3描述符(图形模式显存描述符)
			dd	0x0000ffff
			dd	0x0040920a
			;4描述符(代码段写入描述符)
			dd	0x0000ffff
			dd	0x00cf9200
			;5描述符(堆栈描述符)
			dd	0x00007c00
			dd	0x00409200
		gdt_size		dw gdt_size-gdt-1
		gdt_base		dd gdt		;GDT的物理地址
		
		idt:
			;在此安装中断/陷阱/任务门描述符
			dd	0x00080000+int_0
			dd	0x00008e00
			dd	0x00080000+int_1
			dd	0x00008e00
			dd	0x00080000+int_2
			dd	0x00008e00
			dd	0x00080000+int_3
			dd	0x00008e00
			dd	0x00080000+int_4
			dd	0x00008e00
			dd	0x00080000+int_5
			dd	0x00008e00
			dd	0x00080000+int_6
			dd	0x00008e00
			dd	0x00080000+int_7
			dd	0x00008e00
			dd	0x00080000+int_8
			dd	0x00008e00
			dd	0x00080000+int_9
			dd	0x00008e00
			dd	0x00080000+int_10
			dd	0x00008e00
			dd	0x00080000+int_11
			dd	0x00008e00
			dd	0x00080000+int_12
			dd	0x00008e00
			dd	0x00080000+int_13
			dd	0x00008e00
			dd	0x00080000+int_14
			dd	0x00008e00
			dd	0x00080000+int_15
			dd	0x00008e00
			dd	0x00080000+int_16
			dd	0x00008e00
			dd	0x00080000+int_17
			dd	0x00008e00
			dd	0x00080000+int_18
			dd	0x00008e00
			dd	0x00080000+int_19
			dd	0x00008e00
			times	12*8	db	0
			dd	0x00080000+int_Timer
			dd	0x00008e00
			dd	0x00080000+int_Keyboard
			dd	0x00008e00
			dd	0x00080000+int_Slave_8259A
			dd	0x00008e00
			dd	0x00080000+int_35
			dd	0x00008e00
			dd	0x00080000+int_36
			dd	0x00008e00
			dd	0x00080000+int_37
			dd	0x00008e00
			dd	0x00080000+int_38
			dd	0x00008e00
			dd	0x00080000+int_39
			dd	0x00008e00
			dd	0x00080000+int_40
			dd	0x00008e00
			dd	0x00080000+int_41
			dd	0x00008e00
			dd	0x00080000+int_42
			dd	0x00008e00
			dd	0x00080000+int_43
			dd	0x00008e00
			dd	0x00080000+int_Mouse
			dd	0x00008e00
			dd	0x00080000+int_45
			dd	0x00008e00
			dd	0x00080000+int_46
			dd	0x00008e00
			dd	0x00080000+int_47
			dd	0x00008e00
		idt_size		dw idt_size-idt-1
		idt_base		dd idt		;GDT的物理地址
[bits 32]
	%macro call_draw_points 3	;word x;word y;dword color;
		push	dword %3
		push	word %2
		push	word %1
		call	draw_points
	%endmacro
	
	
	%macro	call_draw_lines	4	;word x;word y;word length;dword color;
		push	dword %4
		push	word %3
		push	word %2
		push	word %1
		call	draw_lines
	%endmacro
	
	%macro	call_draw_square	5	;word x;word y;word length;word height;dword color
		push	dword %5
		push	word %4
		push	word %3
		push	word %2
		push	word %1
		call	draw_square
	%endmacro
	
	%macro	call_write_font	4
		push	dword %4
		push	dword %3
		push	word %2
		push	word %1
		call	write_font
	%endmacro
	
	%macro	call_write_string	4
		push	dword %4
		push	dword %3
		push	word %2
		push	word %1
		call	write_string
	%endmacro
	
	%macro	call_hex2str16	2
		push	dword %2
		push	word %1
		call	hex2str16
	%endmacro
	
	%macro	call_hex2str32	2
		push	dword %2
		push	dword %1
		call	hex2str32
	%endmacro
	
	%macro	call_get_layer_width	1
		push	word %1
		call	get_layer_width
	%endmacro
	
	%macro	call_get_layer_length	1
		push	word %1
		call	get_layer_length
	%endmacro
	
	%macro	call_get_layer_addr		1
		push	word %1
		call	get_layer_addr
	%endmacro
	
	%macro call_layer_draw_points 3	;word x;word y;dword color;word layer
		push	word %4
		push	dword %3
		push	word %2
		push	word %1
		call	layer_draw_points
	%endmacro
	
	%macro	call_re_pix	2	;word x;word y
		push	word %2
		push	word %1
		call	re_pix
	%endmacro
	
	%macro	call_re_mouse_point	2
		push	word %2
		push	word %1
		call	re_mouse_point
	%endmacro
	
	%macro	call_LBA28_read	3	;dword LBA;word number(扇区);dword addr
		push	dword %3		;addr
		push	word %2		;number
		push	dword %1	;LBA
		call	LBA_read
	%endmacro
	
	%macro	call_get_next_clu	1
		push	dword %1
		call	get_next_clu
	%endmacro
	
	%macro	call_data_load	2
		push	dword %2
		push	dword %1
		call	data_load
	%endmacro
	
	%macro	call_get_file_clu	1
		push	dword %1
		call	get_file_clu
	%endmacro
	
	%macro	call_load_file	2
		push	dword %2
		push	dword %1
		call	load_file
	%endmacro
	
	%macro	call_read_file	2
		push	dword %2
		push	dword %1
		call	read_file
	%endmacro
inti:
	;初始化堆栈及各个段寄存器
	mov		ax,0x28
	mov		ss,ax
	mov		esp,0x7c00
	mov		ax,0x20
	mov		fs,ax
	mov		gs,ax
	mov		ds,ax
	mov		es,ax

	;初始化8259A
	call	inti_8259A
	;键盘、鼠标控制器初始化
	call	ready_keyboard
	call	enable_mouse
	call	inti_mouse
	call_draw_square	0,0,0x400,0x300,0xffffff
	;显示系统名字
	call_write_string	0,0,os_name,0x000000
	;得到CPU品牌信息
	call	get_cpuid
	;屏幕输出CPU品牌信息
	call_write_string	0,16,cpu_ome,0x0000ff
	;得到内存大小信息
	call	get_memory_size
	;转换为字符串
	call_hex2str32		eax,memory_size_num
	;屏幕输出内存大小
	call_write_string	0,32,memory_size,0xff0000
	sti
	;以下属于测试指令===================================
	call_hex2str32		[ards],ttt
	call_write_string	0,32+16,ttt,0xff0000
	call_hex2str32		[ards+4],ttt+8
	call_write_string	0,32+16,ttt,0xff0000
	call_hex2str32		[ards+8],ttt+16
	call_write_string	0,32+16,ttt,0xff0000
	call_hex2str32		[ards+12],ttt+24
	call_write_string	0,32+16,ttt,0xff0000
	call_hex2str32		[ards+16],ttt+32
	call_write_string	0,32+16,ttt,0xff0000
	jmp		finish

	;系统待机
	finish:
		hlt
		jmp		finish
	
ttt	times	41	db	0
	
par_lba:	dd	0x00000000
sec_byte:	dw	0x0000
clu_sec:	db	0x00
res_sec:	dw	0x0000
fat_num:	db	0x00
root_num:	dw	0x0000
fat_size:	dd	0x00000000
root_start:	dd	0x00000000
data_lba:	dd	0x00000000
fat_lba:	dd	0x00000000
test_string:	db	"        ",0x00
file_name:		db	"BACKDROPPIC"
	;以下属于操作系统功能模块============================
Function_Module:
	read_file:		;dowrd filename_point;dword addr
		push	ebp
		mov		ebp,esp
		add		ebp,4
		push	eax
		mov		eax,[ebp+4]
		call_get_file_clu	eax
		call_load_file		eax,[ebp+8]
		pop		eax
		pop		ebp
		ret		8
		
	get_file_clu:
		push	ebp
		mov		ebp,esp
		add		ebp,4
		push	edi
		push	esi
		mov		edi,0x200000
		mov		esi,[ebp+4]
		call	load_root
		get_file_clu_loop:
			mov		eax,[esi]
			cmp		eax,[edi]
			jnz		get_file_clu_next
			mov		eax,[esi+4]
			cmp		eax,[edi+4]
			jnz		get_file_clu_next
			mov		ax,[esi+8]
			cmp		ax,[edi+8]
			jnz		get_file_clu_next
			mov		al,[esi+10]
			cmp		al,[edi+10]
			jnz		get_file_clu_next
			mov		ax,[edi+0x14]
			shl		eax,16
			mov		ax,[edi+0x1a]
			pop		esi
			pop		edi
			pop		ebp
			ret		4
		get_file_clu_next:
			add		edi,32
			jmp		get_file_clu_loop
			
			
	load_root:
		call_load_file	[root_start],0x200000
		ret
		
	load_file:
		push	ebp
		mov		ebp,esp
		add		ebp,4
		push	ecx
		push	ebx
		push	eax
		push	edx
		xor		edx,edx
		mov		dx,[sec_byte]
		mov		eax,[ebp+4]
		mov		ebx,[ebp+8]
		load_root_loop:
		call_data_load		eax,ebx
		call_get_next_clu	eax
		and		eax,0x0FFFFFFF
		cmp		eax,0x0FFFFFF7
		ja		load_root_finish
		add		ebx,edx
		jmp		load_root_loop
		load_root_finish:
			pop		edx
			pop		eax
			pop		ebx
			pop		ecx
			pop		ebp
			ret		8
		
	data_load:		;dword clu;dword addr
		push	ebp
		mov		ebp,esp
		add		ebp,4
		pushad
		mov		eax,[ebp+4]
		add		eax,[data_lba]
		mov		ebx,[ebp+8]
		call_LBA28_read		eax,1,ebx
		popad
		pop		ebp
		ret		8
		
	get_next_clu:
		push	ebp
		mov		ebp,esp
		add		ebp,4
		push	ecx
		push	edx
		xor		edx,edx
		mov		eax,[ebp+4]
		mov		ecx,128
		div		ecx
		add		eax,[fat_lba]
		call_LBA28_read		eax,1,0x100000
		mov		eax,edx
		mov		ecx,4
		mul		ecx
		mov		edx,eax
		mov		eax,[0x100000+edx]
		pop		edx
		pop		ecx
		pop		ebp
		ret		4
		
	get_par_info:
		push	eax
		push	ecx
		call_LBA28_read		0,1,0x100000		;加载MBR
		mov		eax,[0x100000+0x1be+8]
		mov		[par_lba],eax
		call_LBA28_read		[par_lba],1,0x100000
		mov		ax,[0x100000+0x0b]
		mov		[sec_byte],ax
		mov		al,[0x100000+0x0d]
		mov		[clu_sec],al
		mov		ax,[0x100000+0x0e]
		mov		[res_sec],ax
		mov		al,[0x100000+0x10]
		mov		[fat_num],al
		mov		ax,[0x100000+0x11]
		mov		[root_num],ax
		mov		eax,[0x100000+0x24]
		mov		[fat_size],eax
		mov		eax,[0x100000+0x2c]
		mov		[root_start],eax
		;计算FAT区的起始地址
		xor		ecx,ecx
		mov		cx,[res_sec]
		mov		eax,[par_lba]
		add		eax,ecx
		mov		[fat_lba],eax
		;计算数据区起始地址,分区起始LBA+保留扇区数量+FAT数量*FAT大小
		mov		eax,[fat_size]
		xor		ecx,ecx
		mov		cl,[fat_num]
		mul		ecx
		add		eax,[par_lba]
		mov		cx,[res_sec]
		add		eax,ecx
		sub		eax,2
		mov		[data_lba],eax
		pop		ecx
		pop		eax
		ret
		
	LBA_read:
		push	ebp
		mov		ebp,esp
		add		ebp,4
		pushad

		mov		dx,0x1f2
		mov		ax,[ebp+8]			;扇区数量
		out		dx,al

		mov		eax,[ebp+4]
									;al=LBA地址7~0
		inc		dx					;dx=0x1f3
		out		dx,al
		inc		dx					;dx=0x1f4
		shr		eax,8				;al=LBA地址15~8
		out		dx,al
		inc		dx					;dx=0x1f5
		shr		eax,8				;al=LBA地址23~16
		out		dx,al
		inc		dx
		shr		eax,8				;al=LBA地址27~24
		add		al,11100000b		;LBA模式，主硬盘
		out		dx,al
		mov		dx,0x1f7
		mov		al,0x20
		out		dx,al

			mov		dx,0x1f7
		waits:
			in		al,dx
			and		al,0x88
			cmp		al,0x08
			jnz		waits
			mov		ax,[ebp+8]
			mov		ecx,256
			mul		cx
			mov		cx,ax
			mov		dx,0x1f0
			mov		esi,[ebp+10]
		readw:
			in		ax,dx
			mov		[ds:esi],ax
			add		esi,2
			loop	readw
			popad
			pop		ebp
			ret		10
		
	re_mouse_point:
		push	ebp
		mov		ebp,esp
		add		ebp,4
		pushad
		mov		ax,[ebp+4]
		mov		bx,[ebp+6]
		call_draw_square	[_xmouse],[_ymouse],8,16,0xffffff
		call_write_font		ax,bx,0x00,0x000000
		mov		[_xmouse],ax
		mov		[_ymouse],bx
		popad
		pop		ebp
		ret		4
		inti_mouse:
			pushad
			xor		dx,dx
			mov		ax,[scrx]
			mov		bx,2
			div		bx
			mov		cx,ax
			mov		ax,[scry]
			mov		bx,2
			div		bx
			mov		dx,ax
			call_re_mouse_point		cx,dx
			popad
			ret

	inti_8259A:
		cli
		;设置8259A中断控制器
		mov		al,0x11
		out		0x20,al						;ICW1：边沿触发/级联方式
		mov		al,0x20
		out		0x21,al						;ICW2:起始中断向量
		mov		al,0x04
		out		0x21,al						;ICW3:从片级联到IR2
		mov		al,0x01
		out		0x21,al						;ICW4:非总线缓冲，全嵌套，正常EOI
		mov		al,0x11
		out		0xa0,al						;ICW1：边沿触发/级联方式
		mov		al,0x28
		out		0xa1,al						;ICW2:起始中断向量
		mov		al,0x02;0x04
		out		0xa1,al						;ICW3:从片级联到IR2
		mov		al,0x01
		out		0xa1,al						;ICW4:非总线缓冲，全嵌套，正常EOI
		ret
		
	;键盘鼠标初始化程序
	
		port_keydat				equ	0x0060
		port_keysta				equ	0x0064
		port_keycmd				equ	0x0064
		keysta_send_notready	equ	0x02
		keycmd_write_mode		equ	0x60
		kbc_mode				equ	0x47

		mouse_ready_loop:
			in		al,port_keysta
			and		al,keysta_send_notready
			cmp		al,0x00
			jnz		mouse_ready_loop_2
			ret
			mouse_ready_loop_2:
				jmp		mouse_ready_loop
			
		ready_keyboard:
			call	mouse_ready_loop
			mov		al,keycmd_write_mode
			out		port_keycmd,al
			call	mouse_ready_loop
			mov		al,kbc_mode
			out		port_keydat,al
			ret
			
			
		keycmd_sendto_mouse		equ	0xd4
		mousecmd_enable			equ	0xf4

		enable_mouse:
			call	mouse_ready_loop
			mov		al,keycmd_sendto_mouse
			out		port_keycmd,al
			call	mouse_ready_loop
			mov		al,mousecmd_enable
			out		port_keydat,al
			ret
		
		
	draw_square:
		push	ebp
		mov		ebp,esp
		add		ebp,4
		pushad
		mov		ax,[ebp+4]
		mov		bx,[ebp+6]
		mov		cx,[ebp+8]
		mov		si,[ebp+10]
		mov		edx,[ebp+12]
		draw_square_loop:
		call_draw_lines	ax,bx,cx,edx
		inc		bx
		dec		si
		cmp		si,0x00
		jnz		draw_square_loop
		popad
		pop		ebp
		ret		12
	draw_lines:	
		mov		ebp,esp
		pushad
		mov		ax,[ebp+4]
		mov		bx,[ebp+6]
		mov		si,[ebp+8]
		mov		edx,[ebp+10]
		draw_lines_loop:
		call_draw_points	ax,bx,edx
		dec		si
		inc		ax
		cmp		si,0x00
		jnz		draw_lines_loop
		popad
		ret		10
		
	draw_points:
		push	ebp
		mov		ebp,esp
		add		ebp,4
		pushad
		mov		ax,[ebp+6]
		cmp		ax,[scry]
		ja		draw_points_finish
		;比较是否超越边界
		mov		cx,[scrx]
		mul		cx
		shl		edx,16
		mov		dx,ax
		xor		ebx,ebx
		mov		bx,[ebp+4]
		cmp		bx,[scrx]
		ja		draw_points_finish
		add		edx,ebx
		mov		eax,edx
		mov		ecx,3
		mul		ecx
		add		eax,[vram]
		mov		ecx,[ebp+8]
		mov		[fs:eax],cx
		shr		ecx,16
		mov		[fs:eax+2],cl
		draw_points_finish:
			popad
			pop		ebp
			ret		8
			
			
	write_font:		;word x;word y;byte ascii;dword color;
		mov		ebp,esp
		pushad
		xor		eax,eax
		mov		al,[ebp+8]
		mov		cl,16
		mul		cl
		add		eax,font
		mov		dl,[eax]
		mov		ecx,[ebp+12]
		mov		si,[ebp+4]
		write_font_inti_bh:
			mov		bh,15
			mov		di,[ebp+6]
		write_font_inti_bl:
			mov		bl,7
			add		si,7
		write_font_loop:
			test	dl,1
			jz		write_font_next
			call_draw_points	si,di,ecx
			write_font_next:
				shr		dl,1
				cmp		bl,0x00
				jz		write_font_next2
				dec		bl
				dec		si
				jmp		write_font_loop
		write_font_next2:
			cmp		bh,0x00
			jz		write_font_finish
			cmp		dl,0x00
			jnz		write_font_next3
			inc		eax
			mov		dl,[eax]
			write_font_next3:
			dec		bh
			inc		di
			jmp		write_font_inti_bl
			write_font_finish:
			popad
			ret		12
		
	write_string:
		mov		ebp,esp
		pushad
		mov		esi,[ebp+8]
		mov		ecx,[ebp+12]
		mov		ax,[ebp+4]
		mov		bx,[ebp+6]
		write_string_loop:
		mov		dl,[esi]
		cmp		dl,0x00
		jz		write_string_finish
		call_write_font		ax,bx,edx,ecx
		inc		esi
		add		ax,8
		jmp		write_string_loop
		write_string_finish:
		popad
		ret		12
		
	get_cpuid:
		xor		eax,eax
		cpuid
		mov		[cpu_ome],ebx
		mov		[cpu_ome+4],edx
		mov		[cpu_ome+8],ecx
		ret
		
	hex2str32:
		push	ebp
		mov		ebp,esp
		add		ebp,4
		pushad
		mov		eax,[ebp+4]
		mov		ebx,[ebp+8]
		add		ebx,4
		call_hex2str16	ax,ebx
		sub		ebx,4
		shr		eax,16
		call_hex2str16	ax,ebx
		popad
		pop		ebp
		ret		8
		
	hex2str16:
		push	ebp
		mov		ebp,esp
		add		ebp,4
		pushad
		mov		ax,[ebp+4]
		hex2str32_byte0:
			mov		dl,al
			and		dl,0x0f
			cmp		dl,0x09
			jna	hex2str32_byte0_dec
		hex2str32_byte0_hex:
			;十六进制时
			add		dl,0x37
			mov		ch,dl
			jmp		hex2str32_byte1
		hex2str32_byte0_dec:
			;十进制时
			add		dl,0x30
			mov		ch,dl
			jmp		hex2str32_byte1
		hex2str32_byte1:
			mov		dl,al
			shr		dl,4
			and		dl,0x0f
			cmp		dl,0x09
			jna	hex2str32_byte1_dec
			;十六进制时
			add		dl,0x37
			mov		cl,dl
			jmp		hex2str32_byte2
		hex2str32_byte1_dec:
			;十进制时
			add		dl,0x30
			mov		cl,dl
			jmp		hex2str32_byte2
		hex2str32_byte2:
			mov		dl,ah
			and		dl,0x0f
			cmp		dl,0x09
			jna	hex2str32_byte2_dec
			;十六进制时
			add		dl,0x37
			mov		bh,dl
			jmp		hex2str32_byte3
			;十进制时
		hex2str32_byte2_dec:
			add		dl,0x30
			mov		bh,dl
			jmp		hex2str32_byte3
		hex2str32_byte3:
			mov		dl,ah
			shr		dl,4
			and		dl,0x0f
			cmp		dl,0x09
			jna	hex2str32_byte3_dec
			;十六进制时
			add		dl,0x37
			mov		bl,dl
			jmp		hex2str32_finish
		hex2str32_byte3_dec:
			;十进制时
			add		dl,0x30
			mov		bl,dl
			jmp		hex2str32_finish
		hex2str32_finish:
			mov		ax,cx
			shl		eax,16
			mov		ax,bx
			mov		esi,[ebp+6]
			mov		[esi],eax
			popad
			pop		ebp
			ret		6
	get_memory_size:
		push	esi
		mov	esi,0x100000
		mov	eax,esi
		get_memory_size_loop:
			mov		dword[esi],0xaaaa5555
			cmp		dword[esi],0xaaaa5555
			jnz		get_memory_size_finish
			add		eax,0x100000
			add		esi,0x100000
			jmp		get_memory_size_loop
		get_memory_size_finish:	
			pop		esi
			ret
			
	get_layer_width:	;word layerID
		push	ebp
		mov		ebp,esp
		add		ebp,4
		push	dx
		push	esi
		mov		dx,[ebp+4]
		mov		esi,Layers_0_ID
		get_layer_width_loop:
			mov		ax,[esi]
			cmp		ax,dx
			jz		get_layer_width_next
			add		esi,16
			jmp		get_layer_width_loop
		get_layer_width_next:
			mov		ax,[esi+10]
			pop		esi
			pop		dx
			pop		ebp
			ret		2
	
	get_layer_length:	;word layerID
		push	ebp
		mov		ebp,esp
		add		ebp,4
		push	dx
		push	esi
		mov		dx,[ebp+4]
		mov		esi,Layers_0_ID
		get_layer_length_loop:
			mov		ax,[esi]
			cmp		ax,dx
			jz		get_layer_length_next
			add		esi,16
			jmp		get_layer_length_loop
		get_layer_length_next:
			mov		ax,[esi+8]
			pop		esi
			pop		dx
			pop		ebp
			ret		2
			
	get_layer_addr:	;word layerID
		push	ebp
		mov		ebp,esp
		add		ebp,4
		push	dx
		push	esi
		mov		dx,[ebp+4]
		mov		esi,Layers_0_ID
		get_layer_addr_loop:
			mov		ax,[esi]
			cmp		ax,dx
			jz		get_layer_addr_next
			add		esi,16
			jmp		get_layer_addr_loop
		get_layer_addr_next:
			mov		eax,[esi+12]
			pop		esi
			pop		dx
			pop		ebp
			ret		2
			
	;以下是操作系统中断程序部分
	int_0:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_0,0xffffff
		jmp		$
	int_1:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_1,0xffffff
		jmp		$
		iretd
	int_2:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_2,0xffffff
		jmp		$
		iretd
	int_3:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_3,0xffffff
		jmp		$
		iretd
	int_4:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_4,0xffffff
		jmp		$
		iretd
	int_5:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_5,0xffffff
		jmp		$
		iretd
	int_6:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_6,0xffffff
		jmp		$
		iretd
	int_7:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_7,0xffffff
		jmp		$
		iretd
	int_8:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_8,0xffffff
		jmp		$
	int_9:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_9,0xffffff
		jmp		$
		iretd
	int_10:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_10,0xffffff
		jmp		$
		iretd
	int_11:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_11,0xffffff
		jmp		$
		iretd
	int_12:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_12,0xffffff
		iretd
	int_13:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_13,0xffffff
		jmp		$
		iretd
	int_14:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_14,0xffffff
		iretd
	int_15:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_15,0xffffff
		iretd
	int_16:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_16,0xffffff
		iretd
	int_17:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_17,0xffffff
		iretd
	int_18:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_18,0xffffff
		iretd
	;临时设置中断
	int_35:
	int_36:
	int_37:
	int_38:
	int_39:
	int_40:
	int_41:
	int_42:
	int_43:
	int_44:
	int_45:
	int_46:
	int_47:
	int_19:
		call_draw_square	0,0,1024,768,0x0000ff
		call_write_string	0,384,string_int_19,0xffffff
		jmp	$
		iretd
		
	
	int_Timer:
		
		call_draw_square	0,384,400,16,[test_int_Timer]
		call_write_string	0,384,string_int_Timer,[test_int_Timer2]
		add		dword[test_int_Timer],5
		sub		dword[test_int_Timer2],5
		int_Timer_finish:
		mov		al,20h
		out		20h,al
		out		0xa0,al
		iretd
		test_int_Timer:		dd	0x000000
		test_int_Timer2:	dd	0xffffff
	int_Keyboard:
		xor		ax,ax
		in		al,0x60
		call_hex2str16		ax,string_int_Keyboard_num
		call_draw_square	0,400,400,16,0xff0000
		call_write_string	0,400,string_int_Keyboard,0xffffff
		mov		al,20h
		out		20h,al
		out		0xa0,al
		iretd
	int_Slave_8259A:
		call_write_string	0,416,string_int_Slave_8259A,0x000000
		mov		al,20h
		out		20h,al
		out		0xa0,al
		iretd
	int_Mouse:
		pushad
		xor		ax,ax
		in		al,0x60
		cmp		byte[test_Mouse_num],0x00
		jnz		int_Mouse_2
		call_hex2str16		ax,string_int_Mouse_num+1
		inc		byte[test_Mouse_num]
		jmp		int_Mouse_finish
		int_Mouse_2:
		cmp		byte[test_Mouse_num],0x01
		jnz		int_Mouse_3
		mov		[change_mouse_x],al
		call_hex2str16		ax,string_int_Mouse_num+6
		inc		byte[test_Mouse_num]
		jmp		int_Mouse_finish
		int_Mouse_3:
		mov		[change_mouse_y],al
		call_hex2str16		ax,string_int_Mouse_num+11
		call_draw_square	0,416,400,16,0xffff00
		call_write_string	0,416,string_int_Mouse,0x000000
		mov		byte[test_Mouse_num],0x00
		;======================
		xor		ax,ax
		xor		cx,cx
		test	byte[change_mouse_x],10000000b
		jnz		mouse_x_left
		mouse_x_right:
		mov		al,[change_mouse_x]
		add		ax,[_xmouse]
		jmp		mouse_next
		mouse_x_left:
		not		byte[change_mouse_x]
		mov		cl,[change_mouse_x]
		mov		ax,[_xmouse]
		sub		ax,cx
		mouse_next:
		xor		dx,dx
		xor		cx,cx
		test	byte[change_mouse_y],10000000b
		jnz		mouse_y_up
		mouse_y_down:
		mov		cl,[change_mouse_y]
		mov		dx,[_ymouse]
		sub		dx,cx
		jmp		mouse_finish
		mouse_y_up:
		not		byte[change_mouse_y]
		mov		dl,[change_mouse_y]
		add		dx,[_ymouse]
		mouse_finish:
		call_re_mouse_point		ax,dx
		;======================
		int_Mouse_finish:
		mov		al,20h
		out		20h,al
		out		0xa0,al
		popad
		iretd
	test_Mouse_num:		db	0x03
	change_mouse_x:		db		0x00
	change_mouse_y:		db		0x00
	;以下是操作系统全局变量部分
Global_Variables:
	scrx:		dw	0x0000
	scry:		dw	0x0000
	vram:		dd	0x00000000
	cpu_ome:	db	"            ",0x00
	_xmouse:	dw	0x0200
	_ymouse:	dw	0x0180
	
	Layers:
	Layers_0_ID:	dw	0x0000
	Layers_0_x:		dw	0x0000
	Layers_0_y:		dw	0x0000
	Layers_0_z:		dw	0x0000
	Layers_0_length:dw	0x0400
	Layers_0_width:	dw	0x0300
	Layers_0_addr:	dd	0x00100000
	Layers_1_ID:	dw	0x0001
	Layers_1_x:		dw	0x0000
	Layers_1_y:		dw	0x0000
	Layers_1_z:		dw	0x0001
	Layers_1_length:dw	0x0100
	Layers_1_width:	dw	0x0080
	Layers_1_addr:	dd	0x00400000
	Layers_2_ID:	dw	0x0002
	Layers_2_x:		dw	0x0000
	Layers_2_y:		dw	0x0000
	Layers_2_z:		dw	0xffff
	Layers_2_length:dw	0x0010
	Layers_2_width:	dw	0x0010
	Layers_2_addr:	dd	0x420000
	
	
os_name:		db	"Ghost Bird OS!",0x00
memory_size:	db	"Memory Size is 0x"
memory_size_num	db	"        ",0x00
string_int_0:	db	"int 0x00:#DE error!",0x00
string_int_1:	db	"int 0x01:#DB",0x00
string_int_2:	db	"int 0x02",0x00
string_int_3:	db	"int 0x03",0x00
string_int_4:	db	"int 0x04",0x00
string_int_5:	db	"int 0x05",0x00
string_int_6:	db	"int 0x06:#UD error!",0x00
string_int_7:	db	"int 0x07",0x00
string_int_8:	db	"int 0x08",0x00
string_int_9:	db	"int 0x09",0x00
string_int_10:	db	"int 0x0A",0x00
string_int_11:	db	"int 0x0B",0x00
string_int_12:	db	"int 0x0C",0x00
string_int_13:	db	"int 0x0D:#GP error!",0x00
string_int_14:	db	"int 0x0E",0x00
string_int_15:	db	"int 0x0F",0x00
string_int_16:	db	"int 0x10",0x00
string_int_17:	db	"int 0x11",0x00
string_int_18:	db	"int 0x12",0x00
string_int_19:	db	"int 0x13",0x00
string_int_Timer:		db	"int 0x20:Timer Interrupt",0x00
string_int_Keyboard:	db	"int 0x21:Keyboard Interrupt code:0x"
string_int_Keyboard_num:db	"    ",0x00
string_int_Slave_8259A:	db	"int 0x22:Slave 8259A Interrupt",0x00
string_int_Mouse:		db	"int 0x2c:Mouse Interrupt"
string_int_Mouse_num:	db	"(    ,    ,    )",0x00
	;操作系统临时鼠标指针

	;操作系统临时字体部分
font:
		;临时：鼠标指针
		db	10000000b
		db	11000000b
		db	10100000b
		db	10010000b
		db	10001000b
		db	10000100b
		db	10000010b
		db	10001111b
		db	10001000b
		db	10101000b
		db	11010110b
		db	10001010b
		db	00000110b
		db	00000000b
		db	00000000b
		db	00000000b
		times	32*16-($-font)	db	0
		;SPACE
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;!
		db	00000000b
		db	00000000b
		db	00000000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00000000b
		db	00000000b
		db	00011000b
		db	00011000b
		db	00000000b
		db	00000000b
		;"
		db	00000000b
		db	01100110b
		db	01100110b
		db	00100100b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;#
		db	00000000b
		db	00000000b
		db	00000000b
		db	00100100b
		db	00100100b
		db	00100100b
		db	11111110b
		db	01001000b
		db	01001000b
		db	01001000b
		db	11111110b
		db	01001000b
		db	01001000b
		db	01001000b
		db	00000000b
		db	00000000b
		;$
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;%
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;&
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;'
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;(
		db	00000000b
		db	00000100b
		db	00001000b
		db	00010000b
		db	00010000b
		db	00100000b
		db	00100000b
		db	00100000b
		db	00100000b
		db	00100000b
		db	00100000b
		db	00010000b
		db	00010000b
		db	00001000b
		db	00000100b
		db	00000000b
		;)
		db	00000000b
		db	00100000b
		db	00010000b
		db	00001000b
		db	00001000b
		db	00000100b
		db	00000100b
		db	00000100b
		db	00000100b
		db	00000100b
		db	00000100b
		db	00001000b
		db	00001000b
		db	00010000b
		db	00100000b
		db	00000000b
		;*
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;+
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;,
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00001110b
		db	00001100b
		db	00011000b
		db	00100000b
		;-
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;.
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00110000b
		db	00110000b
		db	00000000b
		db	00000000b
		times	48*16-($-font)	db	0
		;0
		db	00000000b
		db	00000000b
		db	00000000b
		db	00011000b
		db	00100100b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	00100100b
		db	00011000b
		db	00000000b
		db	00000000b
		;1
		db	00000000b
		db	00000000b
		db	00000000b
		db	00010000b
		db	01110000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	01111100b
		db	00000000b
		db	00000000b
		;2
		db	00000000b
		db	00000000b
		db	00000000b
		db	00111100b
		db	01000010b
		db	01000010b
		db	01000010b
		db	00000100b
		db	00000100b
		db	00001000b
		db	00010000b
		db	00100000b
		db	01000010b
		db	01111110b
		db	00000000b
		db	00000000b
		;3
		db	00000000b
		db	00000000b
		db	00000000b
		db	00111100b
		db	01000010b
		db	01000010b
		db	00000100b
		db	00011000b
		db	00000100b
		db	00000010b
		db	00000010b
		db	01000010b
		db	01000100b
		db	00111000b
		db	00000000b
		db	00000000b
		;4
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000100b
		db	00001100b
		db	00010100b
		db	00100100b
		db	00100100b
		db	01000100b
		db	01000100b
		db	01111110b
		db	00000100b
		db	00000100b
		db	00011110b
		db	00000000b
		db	00000000b
		;5
		db	00000000b
		db	00000000b
		db	00000000b
		db	01111110b
		db	01000000b
		db	01000000b
		db	01000000b
		db	01011000b
		db	01100100b
		db	00000010b
		db	00000010b
		db	01000010b
		db	01000100b
		db	00111000b
		db	00000000b
		db	00000000b
		;6
		db	00000000b
		db	00000000b
		db	00000000b
		db	00011100b
		db	00100100b
		db	01000000b
		db	01000000b
		db	01011000b
		db	01100100b
		db	01000010b
		db	01000010b
		db	01000010b
		db	00100100b
		db	00011000b
		db	00000000b
		db	00000000b
		;7
		db	00000000b
		db	00000000b
		db	00000000b
		db	01111110b
		db	01000100b
		db	01000100b
		db	00001000b
		db	00001000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00000000b
		db	00000000b
		;8
		db	00000000b
		db	00000000b
		db	00000000b
		db	00111100b
		db	01000010b
		db	01000010b
		db	01000010b
		db	00100100b
		db	00011000b
		db	00100100b
		db	01000010b
		db	01000010b
		db	01000010b
		db	00111100b
		db	00000000b
		db	00000000b
		;9
		db	00000000b
		db	00000000b
		db	00000000b
		db	00011000b
		db	00100100b
		db	01000010b
		db	01000010b
		db	01000010b
		db	00100110b
		db	00011010b
		db	00000010b
		db	00000010b
		db	00100100b
		db	00111000b
		db	00000000b
		db	00000000b
		;:
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00110000b
		db	00110000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00110000b
		db	00110000b
		db	00000000b
		db	00000000b
		;;
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00100000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00100000b
		db	00100000b
		db	01000000b
		;<
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000010b
		db	00000100b
		db	00001000b
		db	00010000b
		db	00100000b
		db	01000000b
		db	00100000b
		db	00010000b
		db	00001000b
		db	00000100b
		db	00000010b
		db	00000000b
		db	00000000b
		;=
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	01111110b
		db	00000000b
		db	00000000b
		db	00000000b
		db	01111110b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;>
		db	00000000b
		db	00000000b
		db	00000000b
		db	01000000b
		db	00100000b
		db	00010000b
		db	00001000b
		db	00000100b
		db	00000010b
		db	00000100b
		db	00001000b
		db	00010000b
		db	00100000b
		db	01000000b
		db	00000000b
		db	00000000b
		times	65*16-($-font)	db	0
		;A
		db	00000000b
		db	00000000b
		db	00000000b
		db	00010000b
		db	00010000b
		db	00011000b
		db	00101000b
		db	00101000b
		db	00100100b
		db	00111100b
		db	01000100b
		db	01000010b
		db	01000010b
		db	11100111b
		db	00000000b
		db	00000000b
		;B
		db	00000000b
		db	00000000b
		db	00000000b
		db	11111000b
		db	01000100b
		db	01000100b
		db	01000100b
		db	01111000b
		db	01000100b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000100b
		db	11111000b
		db	00000000b
		db	00000000b
		;C
		db	00000000b
		db	00000000b
		db	00000000b
		db	00111110b
		db	01000010b
		db	01000010b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10000000b
		db	01000010b
		db	01000100b
		db	00111000b
		db	00000000b
		db	00000000b
		;D
		db	00000000b
		db	00000000b
		db	00000000b
		db	11111000b
		db	01000100b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000100b
		db	11111000b
		db	00000000b
		db	00000000b
		;E
		db	00000000b
		db	00000000b
		db	00000000b
		db	11111100b
		db	01000010b
		db	01001000b
		db	01001000b
		db	01111000b
		db	01001000b
		db	01001000b
		db	01000000b
		db	01000010b
		db	01000010b
		db	11111100b
		db	00000000b
		db	00000000b
		;F
		db	00000000b
		db	00000000b
		db	00000000b
		db	11111100b
		db	01000010b
		db	01001000b
		db	01001000b
		db	01111000b
		db	01001000b
		db	01001000b
		db	01000000b
		db	01000000b
		db	01000000b
		db	11100000b
		db	00000000b
		db	00000000b
		;G
		db	00000000b
		db	00000000b
		db	00000000b
		db	00111100b
		db	01000100b
		db	01000100b
		db	10000000b
		db	10000000b
		db	10000000b
		db	10001110b
		db	10000100b
		db	01000100b
		db	01000100b
		db	00111000b
		db	00000000b
		db	00000000b
		;H
		db	00000000b
		db	00000000b
		db	00000000b
		db	11100111b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01111110b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	11100111b
		db	00000000b
		db	00000000b
		;I
		db	00000000b
		db	00000000b
		db	00000000b
		db	01111100b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	01111100b
		db	00000000b
		db	00000000b
		;J
		db	00000000b
		db	00000000b
		db	00000000b
		db	00111110b
		db	00001000b
		db	00001000b
		db	00001000b
		db	00001000b
		db	00001000b
		db	00001000b
		db	00001000b
		db	00001000b
		db	00001000b
		db	00001000b
		db	10001000b
		db	11110000b
		;K
		db	00000000b
		db	00000000b
		db	00000000b
		db	11101110b
		db	01000100b
		db	01001000b
		db	01010000b
		db	01110000b
		db	01010000b
		db	01001000b
		db	01001000b
		db	01000100b
		db	01000100b
		db	11101110b
		db	00000000b
		db	00000000b
		;L
		db	00000000b
		db	00000000b
		db	00000000b
		db	11100000b
		db	01000000b
		db	01000000b
		db	01000000b
		db	01000000b
		db	01000000b
		db	01000000b
		db	01000000b
		db	01000000b
		db	01000010b
		db	11111110b
		db	00000000b
		db	00000000b
		;M
		db	00000000b
		db	00000000b
		db	00000000b
		db	11101110b
		db	01101100b
		db	01101100b
		db	01101100b
		db	01101100b
		db	01010100b
		db	01010100b
		db	01010100b
		db	01010100b
		db	01010100b
		db	11010110b
		db	00000000b
		db	00000000b
		;N
		db	00000000b
		db	00000000b
		db	00000000b
		db	11000111b
		db	01100010b
		db	01100010b
		db	01010010b
		db	01010010b
		db	01001010b
		db	01001010b
		db	01001010b
		db	01000110b
		db	01000110b
		db	11100010b
		db	00000000b
		db	00000000b
		;O
		db	00000000b
		db	00000000b
		db	00000000b
		db	00111000b
		db	01000100b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	01000100b
		db	00111000b
		db	00000000b
		db	00000000b
		;P
		db	00000000b
		db	00000000b
		db	00000000b
		db	11111100b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01111100b
		db	01000000b
		db	01000000b
		db	01000000b
		db	01000000b
		db	11100000b
		db	00000000b
		db	00000000b
		;Q
		db	00000000b
		db	00000000b
		db	00000000b
		db	00111000b
		db	01000100b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10000010b
		db	10110010b
		db	11001010b
		db	01001100b
		db	00111000b
		db	00000110b
		db	00000000b
		;R
		db	00000000b
		db	00000000b
		db	00000000b
		db	11111100b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01111100b
		db	01001000b
		db	01001000b
		db	01000100b
		db	01000100b
		db	01000010b
		db	11100011b
		db	00000000b
		db	00000000b
		;S
		db	00000000b
		db	00000000b
		db	00000000b
		db	00111110b
		db	01000010b
		db	01000010b
		db	01000000b
		db	00100000b
		db	00011000b
		db	00000100b
		db	00000010b
		db	01000010b
		db	01000010b
		db	01111100b
		db	00000000b
		db	00000000b
		;T
		db	00000000b
		db	00000000b
		db	00000000b
		db	11111110b
		db	10010010b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00111000b
		db	00000000b
		db	00000000b
		;U
		db	00000000b
		db	00000000b
		db	00000000b
		db	11100111b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	00111100b
		db	00000000b
		db	00000000b
		;V
		db	00000000b
		db	00011000b
		db	00011000b
		db	00011000b
		db	00011000b
		db	00100100b
		db	00100100b
		db	00100100b
		db	00100100b
		db	01111110b
		db	01000010b
		db	01000010b
		db	01000010b
		db	11100111b
		db	00000000b
		db	00000000b
		;W
		db	00000000b
		db	00011000b
		db	00011000b
		db	00011000b
		db	00011000b
		db	00100100b
		db	00100100b
		db	00100100b
		db	00100100b
		db	01111110b
		db	01000010b
		db	01000010b
		db	01000010b
		db	11100111b
		db	00000000b
		db	00000000b
		;X
		db	00000000b
		db	00000000b
		db	00000000b
		db	11100111b
		db	01000010b
		db	00100100b
		db	00100100b
		db	00011000b
		db	00011000b
		db	00011000b
		db	00100100b
		db	00100100b
		db	01000010b
		db	11100111b
		db	00000000b
		db	00000000b
		;Y
		db	00000000b
		db	00011000b
		db	00011000b
		db	00011000b
		db	00011000b
		db	00100100b
		db	00100100b
		db	00100100b
		db	00100100b
		db	01111110b
		db	01000010b
		db	01000010b
		db	01000010b
		db	11100111b
		db	00000000b
		db	00000000b
		;Z
		db	00000000b
		db	00011000b
		db	00011000b
		db	00011000b
		db	00011000b
		db	00100100b
		db	00100100b
		db	00100100b
		db	00100100b
		db	01111110b
		db	01000010b
		db	01000010b
		db	01000010b
		db	11100111b
		db	00000000b
		db	00000000b
		;[
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;"\"
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;]
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;^
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;_
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;'
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;a
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	01111000b
		db	10000100b
		db	00111100b
		db	01000100b
		db	10000100b
		db	10000100b
		db	01111110b
		db	00000000b
		db	00000000b
		;b
		db	00000000b
		db	00000000b
		db	00000000b
		db	11000000b
		db	01000000b
		db	01000000b
		db	01000000b
		db	01011000b
		db	01100100b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01100100b
		db	01011000b
		db	00000000b
		db	00000000b
		;c
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00011100b
		db	00100010b
		db	01000000b
		db	01000000b
		db	01000000b
		db	00100010b
		db	00011100b
		db	00000000b
		db	00000000b
		;d
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000110b
		db	00000010b
		db	00000010b
		db	00000010b
		db	00011110b
		db	00100010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	00100110b
		db	00011011b
		db	00000000b
		db	00000000b
		;e
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00111100b
		db	01000010b
		db	01111110b
		db	01000000b
		db	01000000b
		db	01000010b
		db	00111100b
		db	00000000b
		db	00000000b
		;f
		db	00000000b
		db	00000000b
		db	00000000b
		db	00011110b
		db	00100010b
		db	00100000b
		db	00100000b
		db	11111100b
		db	00100000b
		db	00100000b
		db	00100000b
		db	00100000b
		db	00100000b
		db	11111000b
		db	00000000b
		db	00000000b
		;g
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;h
		db	00000000b
		db	00000000b
		db	00000000b
		db	11000000b
		db	01000000b
		db	01000000b
		db	01000000b
		db	01011100b
		db	01100010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	11100111b
		db	00000000b
		db	00000000b

		;i
		db	00000000b
		db	00000000b
		db	00000000b
		db	00110000b
		db	00110000b
		db	00000000b
		db	00000000b
		db	01110000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	01111100b
		db	00000000b
		db	00000000b
		;j
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;k
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;l
		db	00000000b
		db	00000000b
		db	00000000b
		db	01110000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	01111100b
		db	00000000b
		db	00000000b
		;m
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	11111110b
		db	01001001b
		db	01001001b
		db	01001001b
		db	01001001b
		db	01001001b
		db	11101101b
		db	00000000b
		db	00000000b
		;n
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	11011100b
		db	01100010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	11100111b
		db	00000000b
		db	00000000b
		;o
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00111100b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	00111100b
		db	00000000b
		db	00000000b
		;p
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	11011000b
		db	01100100b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000100b
		db	01111000b
		db	01000000b
		db	11100000b
		;q
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;r
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	11101110b
		db	00110010b
		db	00100000b
		db	00100000b
		db	00100000b
		db	00100000b
		db	11111000b
		db	00000000b
		db	00000000b
		;s
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00111110b
		db	01000010b
		db	01000000b
		db	00111100b
		db	00000010b
		db	01000010b
		db	01111100b
		db	00000000b
		db	00000000b
		;t
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00010000b
		db	00010000b
		db	01111100b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00010000b
		db	00001100b
		db	00000000b
		db	00000000b
		;u
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	1100011b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000010b
		db	01000110b
		db	00111011b
		db	00000000b
		db	00000000b
		;v
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		;w
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	11010111b
		db	10010010b
		db	10010010b
		db	10101010b
		db	10101010b
		db	01000100b
		db	01000100b
		db	00000000b
		db	00000000b
		;x
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	01101110b
		db	00100100b
		db	00011000b
		db	00011000b
		db	00011000b
		db	00100100b
		db	01110110b
		db	00000000b
		db	00000000b
		;y
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	11100111b
		db	01000010b
		db	00100100b
		db	00100100b
		db	00101000b
		db	00011000b
		db	00010000b
		db	00010000b
		db	11100000b
		;z
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	00000000b
		db	01111110b
		db	01000100b
		db	00001000b
		db	00010000b
		db	00010000b
		db	00100010b
		db	01111110b
		db	00000000b
		db	00000000b
times	18*512-($-$$)	db	0