#ifndef VEDIO_H_
#define VEDIO_H_

unsigned int xsize;
unsigned int ysize;

void inti_graph(void);
void put_pix_24(unsigned int x, unsigned int y, unsigned int color);
unsigned int get_pix_24(unsigned int x, unsigned int y);

#endif

