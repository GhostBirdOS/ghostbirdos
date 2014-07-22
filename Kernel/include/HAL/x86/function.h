/*Copyright 2013-2014 by 2013-2014 by Explorer OS Developer. All rights reserved.

Explorer 0.01 x86平台硬件抽象层头文件
File name:Explorer\Kernel\include\HAL\x86\function.h
2014.7.14 1:49 PM
*/
#ifndef FUNCTION_H_
#define FUNCTION_H_

//GDT操作函数
void clean_GDT(void);
unsigned int creat_GDT(unsigned int base_addr, unsigned int length, unsigned int attribute);
void write_GDTR(unsigned int GDT_base, unsigned int GDT_size);
//控制寄存器读写
unsigned int read_cr0(void);
void write_CR0(unsigned int cr0);
unsigned int read_cr3(void);
void write_CR3(unsigned int cr0);
//输入输出函数
void io_hlt(void);
void io_cli(void);
void io_sti(void);
unsigned int io_read_eflags();
void io_write_eflags(int flags);
unsigned char io_in8(unsigned int port);
unsigned short int io_in16(unsigned int port);
unsigned int io_in32(unsigned int port);
void io_out8(unsigned int port, unsigned char data);
void io_out16(unsigned int port, unsigned char data);
void io_out32(unsigned int port, unsigned char data);
//特殊大小内存读写函数
void write_mem24(unsigned int addr, unsigned int data);


#endif

