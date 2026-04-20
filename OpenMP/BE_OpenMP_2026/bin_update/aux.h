#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>


#define MIN(a,b) (((a)<(b))?(a):(b))

long usecs ();
void mysleep(double sec);
int update(int i, int j);
void printx(int *x, int n);
void initx(int *x, int n);
void checkx(int *x, int l);
