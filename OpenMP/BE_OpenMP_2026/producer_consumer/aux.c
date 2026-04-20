#include <stdio.h>      /* printf, scanf, puts, NULL */
#include <stdlib.h>     /* srand, rand */
#include <sys/time.h>       /* time */
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

void consume_data(int *data){
  *data+=1;
  mysleep(0.001 + (double)(rand()%5)/(double)1000);
  return;

}

int produce_data(int idx){
  mysleep(0.001 + (double)(rand()%40)/(double)1000);
  return idx;
}


void random_order(int n, int *arr, int nelems) {

  int *tmp;
  struct timeval t;

  gettimeofday(&t,NULL);
  srand(t.tv_sec);
  
  tmp = (int*)malloc(n*sizeof(int));
  
  // Initialize the array with values from 0 to n-1
  for (int i = 0; i < n; i++) {
    tmp[i] = i ;
  }
  
  // Fisher-Yates shuffle
  for (int i = n - 1; i > 0; i--) {
    int j = rand() % (i + 1);
    // Swap arr[i] and arr[j]
    int temp = tmp[i];
    tmp[i] = tmp[j];
    tmp[j] = temp;
  }

  for (int i = 0; i < nelems; i++) arr[i]=tmp[i];
    
  free(tmp);

  return;
}

void check_result(int *data, int n){
  int i;

  for(i=1; i<n; i++){
    if(data[i]!=i+1){
      printf("The result is incorrect!!!\n");
      return;
    }
  }
  printf("The result is correct!!!\n");
  
}
