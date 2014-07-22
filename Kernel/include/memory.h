#ifndef MEMORY_H
#define MEMORY_H

void inti_memory(void);
unsigned int kmalloc(unsigned int size);
void kfree(unsigned addr, unsigned int size);
unsigned int vremap(unsigned int vir_addr, unsigned int phy_addr, unsigned int size);
void kmemcpy(char *source, char *target, unsigned int count);

#endif