#include "aux.h"
#include <stdio.h>
#include <omp.h>

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


int update(int i, int j){
  
  mysleep(0.005 + 0.0001*(double)i);

  return i+j;
}


void printx(int *x, int n)
{
  for(int i=0; i<n; i++)
    printf("%4d, ",x[i]);
  printf("\n");
}


void initx(int *x, int n)
{
  for(int i=0; i<n; i++)
    x[i]=i;
}

void checkx(int *x, int l)
{
  int n = pow(2,l);
  int *x2 = (int*)malloc(n*sizeof(int));
  int i, j, b, e;
  
  for(i=0; i<n; i++)
    x2[i]=i;

  for(i=1; i<l; i++){
    b = pow(2,(i-1));
    e = pow(2,i)-1;
    for(j=b; j<=e; j++){
      x2[2*j]   = x2[j]+x2[2*j];
      x2[2*j+1] = x2[j]+x2[2*j+1];
    }
  }

  for(i=0; i<n; i++)
    if(x2[i] != x[i]){
      printf("The result is WRONG!!!\n\n");
      free(x2);
      return;
    }

  free(x2);
  printf("The result is CORRECT!!!\n\n");
  return;
  
  
}
