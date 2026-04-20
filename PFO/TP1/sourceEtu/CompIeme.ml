(*  
   CompIeme : float -> float -> float -> int -> float
   retourne la iéme composante d'un triple
   Parametre (x, y, z) i : (float, float, float), int le triplet et l index i
   Resultat : float, la ieme composante 
   Précondition : 1<=i<=3
*)
let compIeme (x, y, z) i =
  if i > 3 
    then failwith "indice incorrect"
else 
  match i with
  1 -> x
  2 -> y
  3 -> z
  