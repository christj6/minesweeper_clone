#ifndef DUST_H_   /* Include guard */
#define DUST_H_

int mineHit(int, int);
int returnValue(int, int);
int winCheck();
int search(int, int);
void exploreLeft(int, int);
void exploreUp(int, int);
void exploreRight(int, int);
void exploreDown(int, int);
void generateMines();
void printBoard();

#endif
