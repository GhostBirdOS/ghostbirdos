/*Copyright 2013-2014 by 2013-2014 by Explorer OS Developer. All rights reserved.

Explorer 0.01 �ڴ�ֲ�
File name:Explorer\Kernel\include\address.h
2014.7.10 2:37 PM
*/

#ifndef ADDRESS_H_
#define ADDRESS_H_
/*�Ե�λ����*/
#define KB  * 1024
#define MB	* 1048576
/*���ڴ�����ͼ�Ķ���*/
#define mem_map_addr	0x30000			/*��ʼ��ַ*/
#define mem_map_size	128 KB			/*�ڴ�γ���*/
#define mem_map_len		(128 KB)/8		/*�����*/
/*���ں��ڴ�����ͼ�Ķ���*/
#define k_mem_map_addr	0x50000
#define k_mem_map_size	64 KB
#define k_mem_map_len	(k_mem_map_size)/8

#endif