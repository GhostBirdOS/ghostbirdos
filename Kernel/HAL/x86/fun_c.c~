/*Copyright 2013-2014 by 2013-2014 by Explorer OS Developer. All rights reserved.

Explorer 0.01 x86平台硬件抽象层
File name:Explorer\Kernel\HAL\x86\fun_c.c
2014.7.14 1:06 PM
*/

#include "../../include/HAL/x86/function.h"

void inti_arch(void)
{
/*
	clean_GDT();
	creat_GDT();
	write_GDTR();
	*/
}

//进入分页模式
void goto_paging(unsigned int pdt_addr)
{
	write_CR3(pdt_addr);
	write_CR0(read_CR0() | 0x80000000);
}
