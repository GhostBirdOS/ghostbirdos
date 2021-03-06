/*
 *Copyright 2013-2014 by 2013-2014 by Explorer OS Developer. All rights reserved.

 *Explorer 0.01 磁盘管理
 *File name:Explorer\Kernel\drivers\hdd.c
 *2014.7.18 5:48 PM
 */
 
#include "../include/hdd.h"


unsigned int LBA_start;

void inti_hdd(void)
{
	char *point;
	point = (char *) kmalloc(512);
	read_disk(0, (unsigned short int*) point, 1);
	kmemcpy((point + 0x1be + 8), &LBA_start, 2);
	kfree(point, 512);
}

void read_disk(unsigned int LBA, unsigned short int *buffer, unsigned short int number)
{
	int point;
	io_out16(0x1f2,number);/*数量*/
	io_out8(0x1f3,(LBA & 0xff));/*LBA地址7~0*/
	io_out8(0x1f4,((LBA >> 8) & 0xff));/*LBA地址15~8*/
	io_out8(0x1f5,((LBA >> 16) & 0xff));/*LBA地址23~16*/
	io_out8(0x1f6,(((LBA >> 24) & 0xff) + 0xe0));/*LBA地址27~24 + LBA模式，主硬盘*/
	io_out8(0x1f7,0x20);/*读扇区*/
	
	for (; (io_in8(0x1f7) & 0x88) != 0x08;)/*循环等待*/
	{
	}
	for (point = 0; point < (number * 256); point += 1)
	{
		buffer[point] = io_in16(0x1f0);
	}
}
