#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <string.h>
#include <math.h>
#include "omp.h"
#include "aux.h"


void out_of_place_cast(long n, float *xs, double *xd);
void in_place_cast(long n, float *xs);
void check(long n, float *xs, double *xd);


int main(int argc, char **argv){
  long n, i, s, t;
  long  t_start, t_end;
  float *xs, *xsd;
  double *xd, *xdd;
  
  // Command line arguments
  if ( argc == 2 ) {
    n = atoi(argv[1]);    /* size of x */
  } else {
    printf("Usage:\n\n ./main n\n where n is the size of the array to be cast.\n");
    return 1;
  }
  
  xs  = (float*) malloc(n*sizeof(float));
  xd  = (double*) malloc(n*sizeof(double));
  xsd = (float*) malloc(n*sizeof(double));
  xdd = (double*) xsd;

  /* init arrays with random values */
  for(i=0; i<n; i++){
    xs[i] = (float)rand()/(float)(RAND_MAX/10.0);
    xsd[i] = xs[i];
  }
  
  printf("===== Out-of-place cast =======================================\n");
  t_start = usecs();
  out_of_place_cast(n, xs, xd);
  t_end = usecs();
  printf("Execution   time oop : %8.2f msec.\n",((double)t_end-t_start)/1000.0);
  check(n, xs, xd);

  printf("\n===== In-place cast ===========================================\n");
  t_start = usecs();
  in_place_cast(n, xsd);
  t_end = usecs();
  printf("Execution   time  ip : %8.2f msec.\n",((double)t_end-t_start)/1000.0);
  check(n, xs, xdd);

  /* Uncomment this to print the beginning and end of arrays */
  /* printf("\n\n"); */
  /* for(i=0; i<5; i++) */
  /*   printf("%10d -- xs:%8.5f xd:%8.5f  xdd:%8.5f\n",i, xs[i], xd[i], xdd[i]); */
  /* printf("       ...\n"); */
  /* for(i=n-5; i<n; i++) */
  /*   printf("%10d -- xs:%8.5f xd:%8.5f  xdd:%8.5f\n",i, xs[i], xd[i], xdd[i]); */

  return 0;

}


void out_of_place_cast(long n, float *xs, double *xd){

  long i;
  #pragma omp parallel for num_threads(4) 
  for(i=0; i<n; i++)
    xd[i] = (double) xs[i];

  return;

}


void in_place_cast(long n, float *xs){

  long i;
  double *xd;
  
  /* make xd point to the xs array */
  xd = (double*)xs;
  #pragma omp parallel for if(i>(n/2)) num_threads(4)
  for(i=n-1; i>=n/2; i--){
    xd[i] = (double) xs[i];
  }
  for(i=n/2; i>=0; i--){
    xd[i] = (double) xs[i];
  }
}



void check(long n, float *xs, double *xd){

  long i;
  double max, d;

  max = 0;
  for(i=0; i<n; i++){
    d = fabs((((double)xs[i])-xd[i])/((double)xs[i]));
    if(d>max) max=d;
  }

  printf("Maximum difference is %f\n",max);
  /* Normally, max should be equal to zero... */
  if(max<1e-6){
    printf("The result is correct.\n");
  } else {
    printf("The result is wrong!!!\n");
  }
}

/* ================================================================== */
/*

n = 2^20

With 1 thread and
  -> in-place cast tends to be faster than out-of-place cast
With 2 threads and
  -> out-of-place cast tends to be faster than in-place cast
With 4 threads
  -> both are quick but in-place cast is faster on average

*/