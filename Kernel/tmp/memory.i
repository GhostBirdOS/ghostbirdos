# 1 "memory\\memory.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "memory\\memory.c"

# 1 "memory\\/..\\include\\address.h" 1
# 3 "memory\\memory.c" 2
# 1 "memory\\/..\\include\\memory.h" 1



void inti_memory(void);
unsigned int kmalloc(unsigned int size);
void kfree(unsigned addr, unsigned int size);
unsigned int vremap(unsigned int vir_addr, unsigned int phy_addr, unsigned int size);
void kmemcpy(char *source, char *target, unsigned int count);
# 4 "memory\\memory.c" 2


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
# 28 "memory\\memory.c"
void inti_memory(void)
{

 mem_map = (struct mem_map *) 0x30000;
 k_mem_map = (struct k_mem_map *) 0x50000;
 unsigned int offset;

 for (offset = 0; mem_map[offset].end != 0; offset ++)
 {
  k_mem_map[offset].start = mem_map[offset].start;
  if (mem_map[offset].end >= 256 * 1048576)
  {
   k_mem_map[offset].end = 256 * 1048576;
  }else{
   k_mem_map[offset].end = mem_map[offset].end;
  }
 }


 for (offset = 0; mem_map[offset].start <= 256 * 1048576 & mem_map[offset].start != 0; offset ++)
 {
  if (mem_map[offset].end <= 256 * 1048576)
  {
   mem_map[offset].start = 0;
   mem_map[offset].end = 0;
  }else{
   mem_map[offset].start = 256 * 1048576;
  }
 }

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

 if ((size & 0xfff) != 0)
 {
  size = ((size & 0xfffff000) + 0x1000);
 }
 for (offset = 0; offset < (64 * 1024)/8; offset ++)
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

 printk("kmalloc is error!");
 io_hlt();
}

void kfree(unsigned addr, unsigned int size)
{
}

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
