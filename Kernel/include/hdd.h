#ifndef HDD_H_
#define HDD_H_

unsigned int LBA_start;
void inti_hdd(void);
void read_disk(unsigned int LBA, unsigned short int *buffer, unsigned short int number);

#endif

