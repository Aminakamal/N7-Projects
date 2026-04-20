(* j ai un probleme avec plus_listes 
open GrandNombre

module IntListBigNum : sig

  include IGrandNombre with type t = bool * int list

  val comparer_listes : int list -> int list -> int

  val plus_listes : int list -> int list -> int list

  val moins_listes : int list -> int list -> int list

  val mult_coeff : int list -> int -> int list

end = struct
  (* Type pour le grand nombre *)
  type t = bool * int list

  (* normalise : int list -> int list
     Normalise une liste de chiffres, c'est à dire retire autant de 0
     que possible du début du nombre.
     Paramètres :
         n : int list, nombre à normaliser (list de chiffre)
     Retour : n' tel que n et n' représentent le même nombre, mais n' ne
     commence pas par 0
  *)
  let normalise n =
    List.fold_right (fun t nq -> if t = 0 && nq = [] then [] else t::nq) n []

  let%test "normalise-1" = (normalise [1;2;3;0;0;0;0;0] = [1;2;3])
  let%test "normalise-2" = (normalise [1;0;1;0;1;0;1;0] = [1;0;1;0;1;0;1])
  let%test "normalise-3" = (normalise [2] = [2])
  let%test "normalise-4" = (normalise [] = [])
  let%test "normalise-5" = (normalise [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0] = [])

 let from_int n = (false,[])(*  if n = 0 then (false,[])
                  else 
                    let aux acc  = let liste_ent = (List.fold_left(fun a l x ->  (x mod a )  ) 100 [] acc) in 
                    if n >0 then (false,liste_ent)
                    else (true,liste_ent)
                    in aux [n] *)
(* Tests : TO DO *)

  let rec from_digits signum chiffres = (false,[]) (* match chiffres with
                                    |[] -> (signum,[])
                                    |[0] ->  (signum,[])
                                    
                                    |x::y::q -> let l = [IntListBigNum.plus (IntListBigNum.mult x (IntListBigNum.from_int 10)) y] in
                                                (signum,l@(from_digits q) )
                                  *)
(*
let%test "from_digits-0" = (from_digits false [0;0] = (false, []))
let%test "from_digits-1" = (from_digits false [1;2;3;4;5;6;7] = (false, [67;45;23;1]))
let%test "from_digits-2" = (from_digits true [0;0;0;4;2] = (true, [42]))
let%test "from_digits-3" = (from_digits false [1;0;0;0;0] = (false, [0;0;1]))
let%test "from_digits-4" = (from_digits true [] = (true, []))
let%test "from_digits-5" = (from_digits true [9] = (true, [9]))
*)

  let afficher_list =
    let rec afficher_aux fmt = function
      | [] -> ()
      | d :: q -> Format.fprintf fmt "%a%.2d" afficher_aux q d
    in
    fun fmt l ->
      match l with
      | [] -> Format.pp_print_char fmt '0'
      | _ -> afficher_aux fmt l

  let afficher (s,n) =
    Format.printf "%t%a"
      (fun fmt -> if s then Format.pp_print_char fmt '-' else ())
      afficher_list n


  (* comparer_listes : int list -> int list -> int
     Compare deux listes pour savoir laquelle représente le nombre le plus grand.
     Paramètres :
         n1,n2 : int list, nombres à comparer (liste de chiffres)
     Retour : > 0 si n1 > n2, < 0 si n2 > n1, = 0 sinon
  *)
  let rec comparer_listes n1 n2 = (*let n11= List.rev n1 in
                                   let n22 =  List.rev n2 in*)
                                   List.compare(n1 n2)
(*
let%test "comparer_listes-0" = (comparer_listes [] [] = 0)
let%test "comparer_listes-1" = (comparer_listes [12] [] > 0)
let%test "comparer_listes-2" = (comparer_listes [] [12] < 0)
let%test "comparer_listes-3" = (comparer_listes [78;56;34;12] [78;56;34;12] = 0)
let%test "comparer_listes-4" = (comparer_listes [78;56;34;12] [79;56;34;12] < 0)
let%test "comparer_listes-5" = (comparer_listes [56;34;12] [11;11;11;11] < 0)
*)
let comparer (b1,n1) (b2,n2) = if (Bool.equal b1 b2) then comparer_listes n1 n2
                                  else if b1 then comparer_listes n1 []
                                  else if b2 comparer_listes n2 []
                      

  (* Le module IntListTest, défini en fin de fonction, permet de tester les fonctions sur les grands nombres *)
  (* Tests complémentaires pour les cas limites *)
(*
let%test "comparer-0-1" = (comparer (false,[]) (false,[]) = 0)
let%test "comparer-0-2" = (comparer (false,[]) (true,[]) = 0)
*)

  (* plus_listes : int list -> int list -> int list
     Réalise la somme de deux listes de "chiffres"
     Paramètres :
         n1,n2 : int list, nombres à additionner, sous forme de liste de "chiffres"
     Retour : somme de n1 et n2 (sous forme de liste de "chiffres")
     Le résultat est normalisé
  *)
let rec plus_listes n1 n2 = match n2 ,n2  with
                         | [],[] -> []
                         | _,[]-> n1
                         |[],_-> n2
                         |t::q,h::r -> if t+h mod 100 =0 then [t+h]@(plus_listes q r)
                                      else  [t+h mod 100]@(plus_listes q r)
    
    
                 

(*
let%test "plus_listes-base" = (plus_listes [] [] = []) (* 0 + 0 = 0 *)
let%test "plus_listes-zero-1" = (plus_listes [0] [1] = [1]) (* 0 + 1 = 1 *)
let%test "plus_listes-zero-2" = (plus_listes [34;12] [] = [34;12]) (* 1234+0 = 1234 *)
let%test "plus_listes-nominal-1" = (plus_listes [30;20;10] [1;5] = [31;25;10]) (* 102030 +501 = 102531 *)
let%test "plus_listes-nominal-2" = (plus_listes [4;5;6;7] [6;5;4;3] = [10;10;10;10]) (* 7060504 + 3040506 = 10101010 *)
let%test "plus_listes-carrier-1" = (plus_listes [99;10] [1] = [0;11]) (* 1099 + 1 = 1100 *)
let%test "plus_listes-carrier-2" = (plus_listes [10;5] [90;94] = [0;0;1]) (* 510 + 9490 = 10000*)
*)

  (* moins_listes : int list -> int list -> int list
     Réalise la différence positive de deux listes de "chiffres"
     Paramètres :
         n1,n2 : int list, nombres à soustraire, sous forme de liste de "chiffres"
     Retour : différence entre n1 et n2 (sous forme de liste de "chiffres")
     Pré-conditions : n1 >= n2
     Le résultat est normalisé
  *)
  let moins_listes _ _ = []
(*
let%test "moins_listes-base" = (moins_listes [] [] = [])
let%test "moins_listes-nominal-1" = (moins_listes [10;20;30] [1;1;1] = [9;19;29])
let%test "moins_listes-carrier-1" = (moins_listes [0;10] [1] = [99;9])
let%test "moins_listes-carrier-2" = (moins_listes [0;20;50] [1;20;1] = [99;99;48])
let%test "moins_listes-zero" = (moins_listes [1;2;3] [1;2;3] = [])
*)

  (* Note plus a besoin de moins et moins a besoin de plus ; on les définit
     ensemble. *)
  let rec plus _ _ = (false,[])
  and moins _ _ = (false,[])


  (* mult_coeff : int list -> int -> int list
     Multiplie un grand nombre (une liste de chiffres) par un nombre entier "normal"
     Paramètres :
         n : int list, grand nombre (list de chiffres)
         m : int, entier qui sert de facteur
      Retour : n * m
      Post-conditions : nombre normalisé
  *)
  let mult_coeff _ _ = []
(*
let%test "mult_coeff-0" = mult_coeff [56;34;12] 0 = []
let%test "mult_coeff-1" = mult_coeff [34;12] 2  = [68;24]
let%test "mult_coeff-2" = mult_coeff [34;12] 10 = [40;23;1]
let%test "mult_coeff-3" = mult_coeff [34;12] 51 = [34;29;6]
let%test "mult_coeff-4" = mult_coeff [99;99] 99 = [01;99;98]
*)
  let mult _ _ = (false,[])

  let puiss _ _ = (false,[])
end

(* Décommenter pour lancer les tests ! *)
(*module IntListTest = GrandNombreTest (IntListBigNum)*)
(*module IntListAlgo = GrandNombreAlgorithmes (IntListBigNum)*)
*)