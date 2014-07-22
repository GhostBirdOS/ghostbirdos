/*Explorer 0.01 �ڴ�����ִ���*/
#include "../include/address.h"
#include "../include/memory.h"
#include "../include/address.h"

int *pdt;
int *pt;

struct mem_map{
	unsigned int start;
	unsigned int end;
}(*mem_map);

struct k_mem_map{
	unsigned int start;
	unsigned int end;
}(*k_mem_map);

/*void inti_memory(void)���ܣ�
	�����ں˿ɷ����ڴ������
		�����ڴ�ɷ����������256MB���ں˿ռ�ɷ����ڴ������
	���ڴ�ɷ��������ĵ�256MB��Ϊռ��
	�����ҳģʽ
		����ҳĿ¼��
		����ҳ��
*/
	
void inti_memory(void)
{
	/*ʹ������ָ��ָ���ڴ�ռ�*/
	mem_map = (struct mem_map *) mem_map_addr;
	k_mem_map = (struct k_mem_map *) k_mem_map_addr;
	unsigned int offset;
	/*���ڴ�ֲ�����ͼ�е�256MB�ķֲ�����������ں��ڴ�ֲ�ͼ*/
	for (offset = 0; mem_map[offset].end != 0; offset ++)
	{
		k_mem_map[offset].start = mem_map[offset].start;
		if (mem_map[offset].end >= 256 MB)
		{
			k_mem_map[offset].end = 256 MB;
		}else{
			k_mem_map[offset].end = mem_map[offset].end;
		}
	}
	
	/*���ڴ�ɷ��������ĵ�256MB��Ϊռ��*/
	for (offset = 0; mem_map[offset].start <= 256 MB & mem_map[offset].start != 0; offset ++)
	{
		if (mem_map[offset].end <= 256 MB)
		{
			mem_map[offset].start = 0;
			mem_map[offset].end = 0;
		}else{
			mem_map[offset].start = 256 MB;
		}
	}
	/*����ҳĿ¼���ҳ��*/
	pdt = (int *)kmalloc(4096);
	pt = (int *)kmalloc(4096 * 1024);
	for (offset = 0; offset < 1024; offset ++)
	{
		pdt[offset] = (offset * 0x1000) + (int)pt + 0x103;
	}
	for (offset = 0; offset < 1048576; offset ++)
	{
		pt[offset] = offset * 0x1000 + 0x103;
	}
	goto_paging(pdt);
}

unsigned int kmalloc(unsigned int size)
{
	int offset, addr;
	//Ϊ�˾�����ɣ�Ŀǰ��ʱ�Է�4KB��������ܾ�
	if ((size & 0xfff) != 0)
	{
		size = ((size & 0xfffff000) + 0x1000);
	}
	for (offset = 0; offset < k_mem_map_len; offset ++)
	{
		if ((k_mem_map[offset].end - k_mem_map[offset].start) == size)
		{
			addr = k_mem_map[offset].start;
			k_mem_map[offset].start = 0;
			k_mem_map[offset].end = 0;
			return addr;
		}else if ((k_mem_map[offset].end - k_mem_map[offset].start) > size)
		{
			addr = k_mem_map[offset].start;
			k_mem_map[offset].start += size;
			return addr;
		}
	}
	/*���е�����һ�����������ں��ڴ������*/
	printk("kmalloc is error!");
	io_hlt();
}
/*�ں��ڴ��ͷ�*/
void kfree(unsigned addr, unsigned int size)
{
}
/*����ռ�ӳ��*/
unsigned int vremap(unsigned int vir_addr, unsigned int phy_addr, unsigned int size)
{
	if ((vir_addr & 0xfff) != 0)
	{
		return 1;
	}
	if ((phy_addr & 0xfff) != 0)
	{
		return 2;
	}
	if ((size & 0xfff) != 0)
	{
		return 3;
	}
	for (;size != 0;size -= 0x1000)
	{
		pt[(vir_addr >> 12)] = phy_addr + 0x103;
		phy_addr += 0x1000;
		vir_addr += 0x1000;
	}
	return 0;
}

void kmemcpy(char *source, char *object, unsigned int count)
{
	int i;
	for(i = 0; i < count; i ++)
	{
		object[i] = source[i];
	}
	return;
}

 
