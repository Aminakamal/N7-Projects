#include "aux.h"



int main(int argc, char **argv){
  int    i, j, n, nrooms, nplayers, room, player, next_room, finish;
  int *rooms_list;
  long ts, te;
  
   /* Command line argument */
  if ( argc == 3 ) {
    nrooms    = atoi(argv[1]);    /* the number of rooms */
    nplayers  = atoi(argv[2]);    /* the number of players */
  } else {
    printf("Usage:\n\n ./main nrooms nplayers, nwhere\n");
    printf("nrooms      is the number of rooms\n");
    printf("nplayers    is the number of players\n");
    return 1;
  }

  finish = 0;
  
  init(nplayers, nrooms);
  
  printf("\n==================================================\n");
  printf("The escape game begins\n\n");
  omp_lock_t *locks_room;
  locks_room = (omp_lock_t*)malloc(nrooms*sizeof(omp_lock_t));
  for (i=0; i<nrooms;i++){
    omp_init_lock(&locks_room[i]);
  }
  #pragma omp parallel firstprivate(player,room, next_room) num_threads(nplayers)
  {
    
    player = omp_get_thread_num();
    #pragma omp critical
    {
    room = get_my_first_room(player, nrooms);
   
    }
     printf("Player %2d entering the game from room %2d\n",player,room);
    for (;;){

        next_room = solve_enigma(player, room, nrooms);
        omp_test_lock(&locks_room[next_room]);
        //wait for the room to be free
      if(next_room==-999) {
        printf("There was an error!!!  %2d %2d\n",player,room);    
        break;
      } else if (next_room==1000){
        /* Found the exit door!!! quit the game*/
        printf("Yahi! Player %2d found the exit door!\n",player);
        omp_unset_lock(&locks_room[next_room]);
        break;
        
      } else {
        omp_unset_lock(&locks_room[room]);
        room = next_room;
      }
      
    } 
  }
  for (i=0; i<nrooms;i++){
    omp_destroy_lock(&locks_room[i]);
  }
  free(locks_room);
  printf("Player %2d is out!\n",player);

  printf("\n==================================================\n");

  return 0;
}
