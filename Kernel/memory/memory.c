/*Explorer 0.01 内存管理部分代码*/
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

/*void inti_memory(void)功能：
	建立内核可分配内存区间表
		依据内存可分配区间表建立256MB的内核空间可分配内存区间表
	将内存可分配区间表的低256MB设为占用
	进入分页模式
		建立页目录表
		建立页表
*/
	
void inti_memory(void)
{
	/*使两个表指针指向内存空间*/
	mem_map = (struct mem_map *) mem_map_addr;
	k_mem_map = (struct k_mem_map *) k_mem_map_addr;
	unsigned int offset;
	/*将内存分布区间图中低256MB的分布情况拷贝到内核内存分布图*/
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
	
	/*将内存可分配区间表的低256MB设为占用*/
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
	/*建立页目录表和页表*/
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
	//为了尽快完成，目前暂时对非4KB倍的请求拒绝
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
	/*运行到这里一定遍历完了内核内存区间表*/
	printk("kmalloc is error!");
	io_hlt();
}
/*内核内存释放*/
void kfree(unsigned addr, unsigned int size)
{
}
/*虚拟空间映射*/
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

 
