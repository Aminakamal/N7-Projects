#include <sys/time.h>
#include <stdlib.h>

  

long usecs (){
  struct timeval t;

  gettimeofday(&t,NULL);
  return t.tv_sec*1000000+t.tv_usec;
}


void mysleep(double sec){

  long s, e;
  s=0; e=0;
  s = usecs();
  while(((double) e-s)/1000000 < sec)
    {
      e = usecs();
    }
  return;
}


void init_data(long *x, int n){
  int i;
  long l;
  
  for (i=0; i<n; i++){
    do {
      // Generate a random number between -2 and 2
      l = (rand() % 5) - 2;
    } while (l==0);
    x[i] = l;
  }
  
}

long init_result(){
  return (long)1;
}

void operator(long *a, long *b){
  mysleep(0.01);
  *a = abs(*a)* (*b);

}

