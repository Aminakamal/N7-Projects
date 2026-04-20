#include <stdio.h>      /* printf, scanf, puts, NULL */
#include <stdlib.h>     /* srand, rand */
#include <omp.h>
#include <time.h>       /* time */
long usecs ();
void mysleep(double sec);
void check_result(int *data, int n);
void consume_data(int *data);
int produce_data(int idx);
void random_order(int n, int *arr, int nelems);

