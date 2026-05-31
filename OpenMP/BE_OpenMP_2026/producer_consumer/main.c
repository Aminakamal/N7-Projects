#include "aux.h"

void prod_cons_nodepend(int *data, int *order, int n);
void prod_cons_depend(int *data, int *order, int n);


int main(int argc, char *argv[]){

  int   n, i, idx;
  int   *order, *data;
  long  t_start,t_end;


  if(argc!=2){
    printf("Wrong number of arguments.\n Usage:\n\n\
./main n \n\n where n is the number of data to generate and process.\n");
    return 1;
  }
  
  sscanf(argv[1],"%d",&n);

  data  = (int*)malloc(sizeof(int)*n);
  order = (int*)malloc(sizeof(int)*n);

  t_start = usecs();
  prod_cons_nodepend(data, order, n);
  t_end = usecs();
  printf("\nTasks no depend -- Time (msec.) : %7.1f\n",(t_end-t_start)/1e3);
  check_result(data, n);

  printf("\n");
  
  t_start = usecs();
  prod_cons_depend(data, order, n);
  t_end = usecs();
  printf("Tasks    depend -- Time (msec.) : %7.1f\n",(t_end-t_start)/1e3);
  check_result(data, n);
  
  return 0;
      
}
      


void prod_cons_nodepend(int *data, int *order, int n){
  int i, idx;
  #pragma omp parallel
  {
   #pragma omp master
  
  /* Generate random order */
  #pragma omp task firstprivate(i) priority(10)
  random_order(n, order, n);
  for(i=0; i<n; i++){
    
    {
    idx = order[i];
    data[idx] = produce_data(idx);
    }
  }
  
  /* Generate random order */
  #pragma omp task firstprivate(i) priority(2)
  random_order(n, order, n);
  for(i=0; i<n; i++){
  
     {
    idx = order[i];
    consume_data(data+idx);
     }
  }

}
}



void prod_cons_depend(int *data, int *order, int n){
  int i, idx;
  #pragma omp parallel
  {
  #pragma omp master
  /* Generate random order */
  random_order(n, order, n);
  for(i=0; i<n; i++){
    #pragma omp task private(i) depend(inout:idx) depend(out : data[idx]) depend(in :order[i])
    idx = order[i];
    data[idx] = produce_data(idx);
  }
  
  /* Generate random order */
  random_order(n, order, n);
  for(i=0; i<n; i++){
     #pragma omp task private(i) depend(inout : idx) depend(in : data[idx]) depend(in :order[i])
    idx = order[i];
    consume_data(data+idx);
  }
}
}
