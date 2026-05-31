(* Interface spécifiant un grand nombre et les opérations qu'on peut faire dessus. *)
module type IGrandNombre =
sig
  (* Type support du grand nombre *)
  type t
  (* from_int : int -> t
     Transforme un entier "normal" en grand nombre
     Paramètres :
         x : int, entier à transformer
     Retour : un grand nombre, équivalent de x
  *)
  val from_int : int -> t

  (* from_digits : bool -> int list -> t
     Transforme une suite de chiffre en grand nombre (signé)
     Paramètres :
         signum : bool, true si le nombre doit être négatif
         chiffres : int list, suite de chiffres représentant le grand nombre
     Retour : un grand nombre du signe désiré, composé de la suite de chiffre donnée
     Par exemple : from_digits true [1;2;3;4;5;6] = le grand nombre "-123456"
  *)
  val from_digits : bool -> int list -> t

  (* afficher : t -> unit
     Affiche le grand nombre passé en paramètre
     Paramètres :
         x : t, grand nombre à afficher
     Retour : unit
  *)
  val afficher : t -> unit

  (* comaprer : t -> t -> int
     Compare deux grands nombres, retourne un nombre positif si le premier est
     plus grand que le second, un nombre négatif si le premier est plus petit,
     et 0 s'ils sont égaux.
     Paramètres :
         a, b : t, nombres à comparer
     Retour :
     - si b > a, un nombre négatif
     - si a < b, un nombre positif
     - si a = b, 0
  *)
  val comparer : t -> t -> int

  (* plus : t -> t -> t
     Réalise la somme de deux grands nombres
     Paramètres :
         a, b : t, grands nombres à additionner
     Retour : a + b
  *)
  val plus : t -> t -> t

  (* moins : t -> t -> t
     Réalise la différence de deux grands nombres
     Paramètres :
         a, b : t, grands nombres à soustraire
     Retour : a - b
  *)
  val moins : t -> t -> t

  (* mult : t -> t -> t
     Réalise le produit de deux grands nombres
     Paramètres :
         a, b : t, grands nombres à multiplier
     Retour : a * b
  *)
  val mult : t -> t -> t

  (* puiss : t -> t -> t
     Réalise l'exponentiation entière de deux grands nombres
     Paramètres :
         n : t, radical
         k : t, exposant
     Retour : n ^ k
     Pré-conditions : k >= 0
  *)
  val puiss : t -> t -> t
end

module GrandNombreAlgorithmes (I : IGrandNombre )  =
struct
  (* egal : t -> t -> bool
     Teste l'égalité entre deux grands nombres
     Paramètres :
         a,b : t, nombre à tester
     Retour : vrai ssi a = b
  *)
  let egal a b = (I.comparer a b = 0)

  (* factorielle : t -> t
     Réalise la factorielle du grand nombre en entrée
     Paramètres :
         n : t, nombre dont on veut la factorielle
     Retour : n!, c'est-à-dire n * (n - 1) * (n - 2) * ... * 1
     Pré-conditions : n >= 0
     Post-conditions : n! > 0
  *)
  let rec factorielle n = if (I.comparer n (I.from_int 0) = 0) then (I.from_int 1) 
                      else if (I.comparer n (I.from_int 1) = 0)then (I.from_int 1)
                      else I.mult n (factorielle(I.moins n (I.from_int 1)))

  let%test "fact-0" = I.(egal (from_int 1) (factorielle (from_int 0)))
  let%test "fact-5" = I.(egal (from_int 120) (factorielle (from_int 5)))
  let%test "fact-25" = I.(egal
                            (from_digits false [1;5;5;1;1;2;1;0;0;4;3;3;3;0;9;8;5;9;8;4;0;0;0;0;0;0])
                            (factorielle (from_int 25)))

  let _ = print_string "25! = "; I.(afficher (factorielle (from_int 25))); print_newline ()


  (* pgcd : t -> t -> t
     Calcule le plus grand commun diviseur de deux grands nombres
     Paramètres :
         a, b : t, grands nombres dont on veut le PGCD
     Retourne : si a ou b différent de 0, d est tel que d divse a, d divise b,
                et si d >= d' et d' divise a et b alors d = d'
                si a = b = 0, d = 0 par convention
     Pré-conditions : a, b positifs ou nuls
     Post-conditions : résultat divise a et b, résultat positif ou nul, résultat = 0 si a = b = 0
  *)
  let rec pgcd a b  = (*let  abs x = 
                                   if (I.comparer x (I.from_int 0) > 0) then x else (I.moins (I.from_int 0) x) in*)

                      if  (I.comparer a (I.from_int 0)) <=0  ||   (I.comparer b (I.from_int 0)) <=0  then 
                      (*pgcd((abs a) (abs b))*)
                      failwith " a b strictement positifs"
                      else if (I.comparer a b ) = 0 then a
                      else if (I.comparer a b ) > 0  then pgcd (I.moins a b) a
                      else pgcd a (I.moins b a) 



  let%test "pgcd-0" = I.(egal (from_int 51) (pgcd (from_int 51) (from_int 0)))
  let%test "pgcd-1" = I.(egal (from_int 4) (pgcd (from_int 64) (from_int 28)))
  let%test "pgcd-2" = I.(egal (from_int 1) (pgcd
                                              (from_digits false [7;8;9;2;2;1;6;5;0])
                                              (from_digits false [4;5;1;6;3;3;9;9;1])))
  let%test "pgcd-3" = I.(egal (from_digits false [6;5;5;3;5]) (pgcd
                                                                 (from_digits false [3;0;4;8;6;0;3;0;0;4;5])
                                                                 (from_digits false [6;4;7;1;2;9;2;8;9;6;0])))

end

module GrandNombreTest (I : IGrandNombre) =
struct
  let egal x1 x2 = (I.comparer x1 x2 = 0)
  let%test "from_int/from_digits-cohérence-0-1" = I.(egal (from_int 0) (from_digits false []))
  let%test "from_int/from_digits-cohérence-0-2" = I.(egal (from_int 0) (from_digits true  []))
  let%test "from_int/from_digits-cohérence-1" = I.(egal (from_int 7) (from_digits false [7]))
  let%test "from_int/from_digits-cohérence-2" = I.(egal (from_int 7981) (from_digits false [7;9;8;1]))
  let%test "from_int/from_digits-cohérence-3" = I.(egal (from_int (-10695)) (from_digits true [1;0;6;9;5]))
  let%test "from_int/from_digits-cohérence-unnormalized" = I.(egal (from_int (-10695)) (from_digits true [0;0;0;0;0;0;0;1;0;6;9;5]))

  let%test "comparer-1" =
    let a = I.from_int 9781
    and b = I.from_int 9782
    in I.comparer a b < 0
  let%test "comparer-2" =
    let a = I.from_int (-1771)
    and b = I.from_int 121
    in I.comparer a b < 0
  let%test "comparer-3" =
    let a = I.from_int 0
    and b = I.from_int (-10728)
    in I.comparer a b > 0
  let%test "comparer-4" =
    let a = I.from_digits false [1;0;0;0;0;0;0;0;0;0;0;7;8;9;1;0;1;2]
    and b = I.from_digits false [1;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0]
    in I.comparer a b < 0


  let%test "plus-0-1" =
    let a = I.from_digits false []
    and b = I.from_digits false [1;2;3]
    in I.(egal b (plus a b))
  let%test "plus-0-2" =
    let a = I.from_digits false [1;2;3]
    and b = I.from_digits false []
    in I.(egal a (plus a b))
  let%test "plus-0-3" =
    let a = I.from_digits false [1;2;3]
    and b = I.from_digits true  [1;2;3]
    and r = I.from_digits false []
    in I.(egal r (plus a b))
  let%test "plus-1" =
    let a = I.from_digits false [7;9;9;6;6;8;3;1;2;1]
    and b = I.from_digits false       [2;3;1;0;6;9;6]
    and r = I.from_digits false [7;9;9;8;9;9;3;8;1;7]
    in I.(egal r (plus a b))
  let%test "plus-2" =
    let a = I.from_digits false   [9;9;9;9;9]
    and b = I.from_digits false           [1]
    and r = I.from_digits false [1;0;0;0;0;0]
    in I.(egal r (plus a b))
  let%test "plus-3" =
    let a = I.from_digits true [7;8;1]
    and b = I.from_digits true [1;2;3]
    and r = I.from_digits true [9;0;4]
    in I.(egal r (plus a b))
  let%test "plus-4" =
    let a = I.from_digits false [1;2;5;1]
    and b = I.from_digits true      [5;2]
    and r = I.from_digits false [1;1;9;9]
    in I.(egal r (plus a b))
  let%test "plus-5" =
    let a = I.from_digits true  [7;8;1;9;3]
    and b = I.from_digits false   [7;6;7;2]
    and r = I.from_digits true  [7;0;5;2;1]
    in I.(egal r (plus a b))


  let%test "moins-0" =
    let a = I.from_digits false []
    and b = I.from_digits false []
    and r = I.from_digits false []
    in I.(egal r (moins a b))

  let%test "moins-0-1" =
    let a = I.from_digits false [1;2;3]
    and b = I.from_digits false []
    and r = I.from_digits false [1;2;3]
    in I.(egal r (moins a b))
  let%test "moins-0-2" =
    let a = I.from_digits false []
    and b = I.from_digits false [1;2;3]
    and r = I.from_digits true  [1;2;3]
    in I.(egal r (moins a b))
  let%test "moins-0-3" =
    let a = I.from_digits true  [1;2;3]
    and b = I.from_digits false []
    and r = I.from_digits true  [1;2;3]
    in I.(egal r (moins a b))
  let%test "moins-0-4" =
    let a = I.from_digits false []
    and b = I.from_digits true  [1;2;3]
    and r = I.from_digits false [1;2;3]
    in I.(egal r (moins a b))
  let%test "moins-0" =
    let a = I.from_digits false [1;2;3]
    and b = I.from_digits false [1;2;3]
    and r = I.from_digits false []
    in I.(egal r (moins a b))

  let%test "moins-1" =
    let a = I.from_digits false [3;7;9;8;1;1;2;1]
    and b = I.from_digits false     [8;7;4;1;5;5]
    and r = I.from_digits false [3;7;1;0;6;9;6;6]
    in I.(egal r (moins a b))
  let%test "moins-2" =
    let a = I.from_digits false           [1]
    and b = I.from_digits false [9;9;9;5;7;6]
    and r = I.from_digits true  [9;9;9;5;7;5]
    in I.(egal r (moins a b))
  let%test "moins-3" =
    let a = I.from_digits true  [4;1;7;6]
    and b = I.from_digits false   [5;9;0]
    and r = I.from_digits true  [4;7;6;6]
    in I.(egal r (moins a b))
  let%test "moins-4" =
    let a = I.from_digits true  [1;7;7;3;6;9;1]
    and b = I.from_digits true  [5;0;0;6;3;7;6]
    and r = I.from_digits false [3;2;3;2;6;8;5]
    in I.(egal r (moins a b))

  let%test "mult-0" =
    let a = I.from_digits false [1;2;3]
    and b = I.from_digits false []
    and r = I.from_digits false []
    in I.(egal r (mult a b))
  let%test "mult-1" =
    let a = I.from_digits false []
    and b = I.from_digits false [1;2;3]
    and r = I.from_digits false []
    in I.(egal r (mult a b))
  let%test "mult-2" =
    let a = I.from_digits false [1]
    and b = I.from_digits true  [4;5;6;7;8;9]
    and r = I.from_digits true  [4;5;6;7;8;9]
    in I.(egal r (mult a b))
  let%test "mult-3" =
    let a = I.from_digits true  [1;2;3]
    and b = I.from_digits true  [1;2;3]
    and r = I.from_digits false [1;5;1;2;9]
    in I.(egal r (mult a b))
  let%test "mult-4" =
    let a = I.from_digits false               [7;6;9;8;4;5;1;3;2]
    and b = I.from_digits false                   [1;3;4;5;2;2;1]
    and r = I.from_digits false [1;0;3;5;6;1;1;8;3;8;3;1;4;1;7;2]
    in I.(egal r (mult a b))
  let%test "mult-5" =
    let a = I.from_digits false                           [1;5;5;4;6;5;1;1;3;2;2;2;1;3;4]
    and b = I.from_digits false                               [7;8;9;4;4;3;6;3;2;2;1;3;2]
    and r = I.from_digits false [1;2;2;7;3;0;9;4;3;6;6;4;5;1;7;8;4;9;8;8;9;6;4;6;9;6;8;8]
    in I.(egal r (mult a b))

  let%test "puiss-0" =
    let n = I.from_int 123
    and k = I.from_int 0
    and r = I.from_int 1 in
    egal r (I.puiss n k)
  let%test "puiss-1" =
    let n = I.from_int 123
    and k = I.from_int 1
    and r = I.from_int 123 in
    egal r (I.puiss n k)
  let%test "puiss-2" =
    let n = I.from_digits true                    [2]
    and k = I.from_digits false                 [3;2]
    and r = I.from_digits false [4;2;9;4;9;6;7;2;9;6] in
    egal r (I.puiss n k)
  let%test "puiss-3" =
    let n = I.from_digits true                    [2]
    and k = I.from_digits false                 [3;1]
    and r = I.from_digits true  [2;1;4;7;4;8;3;6;4;8] in
    egal r (I.puiss n k)
  let%test "puiss-4" =
    let n = I.from_digits false [1;4;4;6]
    and k = I.from_digits false   [1;3;1]
    and r = I.from_digits false [9;5;9;5;0;3;0;8;9;7;3;9;3;5;9;0;9;9;2;5;5;9;1;2;4;6;8;0;4;0;8;8;
                                 4;3;8;8;2;6;0;1;2;9;0;4;5;5;8;3;8;4;7;4;7;3;4;5;7;7;1;6;6;4;1;0;2;5;
                                 0;0;2;0;2;0;9;0;0;5;2;9;5;0;6;3;3;0;0;7;0;7;4;0;6;7;3;4;0;2;6;0;1;8;
                                 6;3;8;3;1;4;8;4;3;1;6;4;1;6;2;3;5;1;7;5;2;1;5;9;6;6;4;5;7;0;9;2;2;8;
                                 6;7;9;2;2;9;5;7;8;4;0;4;4;6;5;4;3;8;8;2;4;6;2;6;5;5;1;7;7;9;6;3;1;6;
                                 9;9;4;1;6;7;5;6;8;9;4;2;0;2;4;7;0;9;2;1;1;0;4;2;7;1;0;2;5;8;2;3;4;5;
                                 5;6;1;9;4;2;4;5;4;5;9;7;6;8;5;6;6;1;0;9;4;2;9;5;9;6;6;6;7;4;6;0;4;4;
                                 4;1;6;7;4;3;2;3;9;6;3;2;3;1;4;1;9;7;2;7;5;6;7;9;2;5;9;1;5;2;9;1;0;7;
                                 4;5;9;4;4;0;4;9;1;9;5;7;2;9;9;5;0;6;2;7;9;7;9;6;7;5;4;4;1;5;8;7;4;5;
                                 3;7;3;1;7;8;3;9;9;0;5;4;5;4;3;5;2;4;8;2;2;4;1;5;9;3;7;1;0;4;1;2;8;8;
                                 8;6;6;6;7;0;5;2;7;0;6;6;6;3;1;9;1;5;7;4;6;1;7;0;0;8;2;5;5;8;9;1;3;5;
                                 6;3;3;6;8;2;9;8;1;7;2;7;3;9;0;8;2;4;4;2;1;9;3;6;2;6;9;5;8;0;9;0;4;2;
                                 7;0;1;3;5;2;9;6] in
    egal r (I.puiss n k)

  let _ = print_string "1446^131 = "; I.(afficher (puiss (from_int 1446) (from_int 131))); print_newline ()
end



