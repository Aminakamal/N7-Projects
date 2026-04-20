#include "trace.h"
#include "common.h"

/* This is a sequential routine for the LU factorization of a square
   matrix in block-columns */
void chol_par_tasks(matrix_t A){


  int i, j, k, prio;

  #pragma omp parallel 
  {  
     #pragma omp master
     {
    for(k=0; k<A.NB; k++){
      /* reduce the diagonal block */
     
      #pragma omp task depend(inout: A.blocks[k][k]) firstprivate(k) priority(10)
      potrf(A.blocks[k][k]);
      
      for(i=k+1; i<A.NB; i++){
        prio = i==k+1 ? 3 : 0;
        /* compute the A[i][k] sub-diagonal block */
        
        #pragma omp task depend(inout: A.blocks[i][k]) depend(in: A.blocks[k][k]) firstprivate(i, k) priority(prio)
        trsm(A.blocks[k][k], A.blocks[i][k]);
        for(j=k+1; j<=i; j++){
          prio = i==j && i==k+1 ? 2 : 0;
          /* update the A[i][j] block in the trailing submatrix */
          #pragma omp task  depend(inout: A.blocks[i][j]) depend(in: A.blocks[i][k], A.blocks[j][k]) firstprivate(i, j, k)  priority(prio)
          gemm(A.blocks[i][k], A.blocks[j][k], A.blocks[i][j]);
        }    
      }
    }
  }
}
  return;

}

