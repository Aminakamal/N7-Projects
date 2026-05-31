#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "omp.h"
#include "aux.h"

int sequential_combine(int *x, int n);
int parallel_combine(int *x, int n);


int main(int argc, char **argv){
  int  n, i, result;
  long t_start, t_end;
  int  *x;
  
  // Command line argument: array length
  if ( argc == 2 ) {
    n = atoi(argv[1]);    /* the length of the array */
  } else {
    printf("Usage:\n\n ./main n\n\nwhere n is the length of the array to be used.\n");
    return 1;
  }


  x=(int *)malloc(sizeof(int)*n);

  
  /* Fill the array with random numbers */
  srand(1);
  for (i = 0; i < n; i++) 
    x[i] = rand() % n;

  /* Sequential combination */
  t_start = usecs();
  result = sequential_combine(x, n);
  t_end = usecs();
  printf("Sequential time : %8.2f msec.  ---  Result: %d\n",((double)t_end-t_start)/1000.0, result);
  



  /* Fill the array with random numbers */
  srand(1);
  for (i = 0; i < n; i++) 
    x[i] = rand() % n;

  /* Parallel combination */
  t_start = usecs();
  result = parallel_combine(x, n);
  t_end = usecs();
  printf("Parallel   time : %8.2f msec.  ---  Result: %d\n",((double)t_end-t_start)/1000.0, result);

  
  return 0;
}



int sequential_combine(int *x, int n){
  int i;
  int a, c;

  a = 0;
  c  = init_combination();
  
  for(i=1; i<n; i++){
    a += some_function(x[i]);
    combine(&c, x+i);
  }
  return a*c;
}


int parallel_combine(int *x, int n){
  int i;
  int a, c;
  #pragma omp parallel
  {
    a = 0;
    c  = init_combination();
    #pragma omp for reduction(+:a)
    for(i=1; i<n; i++){
      a += some_function(x[i]);
      #pragma omp critical
      combine(&c, x+i);
    }
  }
  return a*c;

}
