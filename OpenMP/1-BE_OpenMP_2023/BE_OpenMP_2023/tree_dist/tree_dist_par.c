#include "aux.h"

void tree_dist_par(node_t *nodes, int n){

  int node;
  #pragma omp parallel
  #pragma omp master
  for(node=0; node<n; node++){
    #pragma omp task firstprivate(node) shared(nodes)
    {
      nodes[node].weight = process(nodes[node]);
      nodes[node].dist = nodes[node].weight;
    }
  }

  for (node=0; node<n; node++){
    if(nodes[node].p) nodes[node].dist += (nodes[node].p)->dist;
  }
}
