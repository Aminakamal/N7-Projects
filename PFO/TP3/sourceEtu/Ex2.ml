(*** Combinaisons d'une liste ***)

(* CONTRAT 
Fonction qui prend en argument une liste l et un entier positif k, et qui renvoie
la liste de toutes les combinaisons possibles de k éléments dans l. 
Paramètre k, l : le nombre de combinaisons et la liste des elements
Préconditions : n >=0
Resultat: la liste de toutes les combinaisons possibles de k éléments dans l
*)
let rec combinaison k l = 
  if k > List.length l then [] 
  else 
    match k,l with
    | _ , [] ->[]   
    | 0 , _ ->[[]] 
    |_, t::q-> let l1 = List.map (fun comb -> t::comb) (combinaison (k-1) q )in
                let l2 = combinaison k q in
                l1@l2 

(* TESTS *)
let%test "liste vide, k=0" = combinaison  0 []  = [[]]
let%test "liste vide, k>0" = combinaison 1 [] = []
let%test "k=0, liste non vide" = combinaison 0 [1;2;3] = [[]]
let%test "k=1, liste 3 éléments" = combinaison 1 [1;2;3] = [[1]; [2]; [3]]
let%test "combinaison k=3" = combinaison 3 [1;2;3;4] = [[1;2;3]; [1;2;4]; [1;3;4]; [2;3;4]]
let%test "k = longueur liste" = combinaison 3 [1;2;3] = [[1;2;3]]
let%test "k > longueur liste" = combinaison 3 [1;2] = []
