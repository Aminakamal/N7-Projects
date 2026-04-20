open GrandNombre

module PasSiGrandNombre : IGrandNombre =
struct
  type t = int
  let from_int n = n
  let from_digits signum  chiffres = if signum then -1*(List.fold_left(fun acc x ->  acc*10 + x ) 0 chiffres)
                                     else List.fold_left(fun acc x ->  acc*10 + x ) 0 chiffres
  let afficher x = print_int x
  let comparer a b = compare a b
  let plus = (+)
  let moins = (-)
  let mult a b = a * b
  let rec puiss n k  =  if k = 0 then 1
                        else if k = 1 then n
                        else mult n (puiss n (k-1))



end

(* Décommenter pour lancer les tests ! *)
 module PasSiGrandNombreTest = GrandNombreTest (PasSiGrandNombre) 
 module PasSiGrandNombreAlgo = GrandNombreAlgorithmes (PasSiGrandNombre) 



