#include "aux.h"

#define timelim 2.0

int final_room;

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

void random_permutation(int n, int *arr, int nelems) {

  int *tmp;

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

int *lists, *desks;

void init(int nplayers, int nrooms){
  int i, j;


  struct timeval t;

  gettimeofday(&t,NULL);

  srand(t.tv_usec);
  
  lists = (int*)malloc(nplayers*nrooms*sizeof(int));

  for(i=0; i<nplayers; i++){
    random_permutation(nrooms, lists+i*nrooms, nrooms);
  }

  final_room = rand() % nrooms;

  /* printf("final room is %d\n",final_room); */

  /* for(i=0; i<nplayers; i++){ */
    /* printf("player %2d -- ",i); */
    /* for(j=0; j<nrooms; j++) */
      /* printf("%2d, ",lists[i*nrooms+j]); */
    /* printf("\n"); */
  /* } */

  
  return;
}

int get_my_first_room(int player, int nrooms){

  return lists[nrooms*player];
}

int solve_enigma(int player, int room, int nrooms){
  int i, next_room, result;
  
  next_room = -1;
  for(i=0; i<nrooms; i++){
    if(lists[player*nrooms+i]==room){
      next_room=lists[player*nrooms+i+1];
      lists[player*nrooms+i]=-1;
      break;
    }
  }

  if(next_room==-1) {
    printf("Player %2d has already visited room %2d. There must be an error.\n",player,room);
    return -999;
  } else {
    printf("Player %2d is visiting room %2d\n",player, room);
    mysleep(0.1);
#pragma omp critical
    {
      if(room==final_room) {
        /* printf("Yahi! Player %2d found the exit door!\n",player); */
        final_room=-4;
        result= 1000;
      } else {
        result= next_room;
      }
    }
  }
  return result;
}


void check(int nstudents, int nbooks){

  int student, book;;

  for(student=0; student<nstudents; student++){
    for(book=0; book<nbooks; book++){
      if(lists[student*nbooks+book]!=0){
        printf("Student %2d has not read book %2d\n",student,lists[student*nbooks+book]);
        return;
      }
    }
  }

  printf("Good! All students have read all books.\n");
  return;
  
}

/* int update(int i, int nthreads){ */

  /* if(i%nthreads!=omp_get_thread_num()){ */
    /* printf("Error!!! coefficient %4d is updated by thread %2d instead of %2d\n", */
           /* i, omp_get_thread_num(), i%nthreads); */
    /* return -999; */
  /* } else { */
    /* mysleep((double)0.1); */
    /* return i%nthreads; */
  /* } */

/* } */
  
