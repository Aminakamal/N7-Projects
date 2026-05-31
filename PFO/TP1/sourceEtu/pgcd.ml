(*  Exercice à rendre **)
(*  
   pgcd : int -> int -> int 
   Calcule le PGCD de deux nombres entiers passés en paramètres
   Parametre a, b : int, int 
   Resultat : le pgcd des deux entires
   Précondition : a > 0 et b > 0
*)
let rec pgcd a b =
  if a <= 0 || b <= 0
    then failwith " Les deux entiers doivent strictement positifs"
else if  a = b 
  then a 
else if a > b 
  then pgcd (a-b) a
else pgcd a (b-a) 
(*  TO DO : tests unitaires *)
let%test _ = pgcd 2 4 = 2
let%test _ = pgcd 1 1 = 1
let%test _ = pgcd 3 3 = 3
let%test _ = pgcd 5 2 = 1

