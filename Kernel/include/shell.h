/*Copyright 2013-2014 by 2013-2014 by Explorer OS Developer. All rights reserved.

Explorer 0.01 ����Ӳ��ƽ̨��ʼ��
File name:Explorer\Kernel\include\shell.h
2014.7.5 7:08 PM
*/

#ifndef SHELL
#define SHELL

//�ֿ�
extern char font[256*16];
//��Ļ���
extern unsigned int xsize;
extern unsigned int ysize;

void inti_shell(void);
/*���������ʱ�û�����*/
void printk(const char* format, ...);
void debug(unsigned int *address, unsigned int size);
void color(unsigned int color);
void put_font(unsigned char ascii);
void draw_font(unsigned int x, unsigned int y, unsigned int color, unsigned int ascii);

#endif