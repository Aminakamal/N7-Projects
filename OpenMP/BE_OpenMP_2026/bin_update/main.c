#include "aux.h"
#include "omp.h"

void bin_update_seq(int *x, int l);
void bin_update_par_loop(int *x, int l);
void bin_update_par_task(int *x, int l);


int main(int argc, char **argv) {

  int l, n;
  int i, s;
  long ts, te;
  int *x;
  
  if ( argc == 2 ) {
    l = atoi(argv[1]);    /* the number of nodes in the graph */
  } else {
    printf("Usage:\n\n ./main l\n\nsuch that the size of the array is 2^l.\n");
    return 1;
  }
  
  /* Set the seed for the random number generator */
  n = pow(2,l);
  x = (int*)malloc(n*sizeof(int));

  printf("==================================================\n\n");
  printf("Starting sequential execution\n");
  
  for(i=0; i<n; i++)
    x[i]=i;
  ts = usecs();
  bin_update_seq(x, l);
  te = usecs()-ts;
  /* printx(x, n); */
  
  printf("Sequential execution time     : %6ld  msec.\n",te/1000);

  printf("==================================================\n\n");
  printf("Starting parallel loop execution\n");

  for(i=0; i<n; i++)
    x[i]=i;
  ts = usecs();
  bin_update_par_loop(x, l);
  te = usecs()-ts;
  /* printx(x, n); */
  checkx(x, l);

  printf("Parallel loop execution time  : %6ld  msec.\n",te/1000);

  printf("==================================================\n\n");
  printf("Starting parallel task execution\n");

  for(i=0; i<n; i++)
    x[i]=i;
  ts = usecs();
  bin_update_par_task(x, l);
  te = usecs()-ts;
  /* printx(x, n); */
  checkx(x, l);

  printf("Parallel task execution time  : %6ld  msec.\n",te/1000);

  return 0;

}





void bin_update_seq(int *x, int l){
  
  int i, j, b, e;
  
  for(i=1; i<l; i++){
    b = pow(2,(i-1));
    e = pow(2,i)-1;
    for(j=b; j<=e; j++){
      x[2*j]   = update(x[j], x[2*j]);
      x[2*j+1] = update(x[j], x[2*j+1]);
    }
  }
}

void bin_update_par_loop(int *x, int l){
  
  int i, j, b, e;
  #pragma omp parallel  private(i)
  {
    for(i=1; i<l; i++){
      b = pow(2,(i-1));
      e = pow(2,i)-1;
      #pragma omp for
      for(j=b; j<=e; j++){
        x[2*j]   = update(x[j], x[2*j]);
        x[2*j+1] = update(x[j], x[2*j+1]);
      }
    }
  }
}


void bin_update_par_task(int *x, int l){
  
  int i, j, b, e;
  #pragma omp parallel
  {
    #pragma omp master
    {
      for(i=1; i<l; i++){
        #pragma omp task firstprivate(i) depend(out:e,b)
        b = pow(2,(i-1));
        e = pow(2,i)-1;
        for(j=b; j<=e; j++){
          #pragma omp task firstprivate(j) depend(inout : x[2*j],x[2*j+1]) depend(in:x[j])
          x[2*j]   = update(x[j], x[2*j]);
          x[2*j+1] = update(x[j], x[2*j+1]);
        }
      }
    }
  }

}


