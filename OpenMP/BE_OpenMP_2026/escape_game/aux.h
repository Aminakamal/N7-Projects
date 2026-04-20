#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>
#include "omp.h"

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

void random_permutation(int n, int *arr, int nelems);
long usecs ();
void init(int nplayers, int nrooms);
int solve_enigma(int player, int room, int nrooms);
int get_my_first_room(int player, int nrooms);

/* void check(int nstudents, int nbooks); */
