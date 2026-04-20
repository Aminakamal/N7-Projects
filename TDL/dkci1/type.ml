type typ = Bool | Int | Rat | Pointeur of typ | Void | TypeEnum of string | Undefined

let rec string_of_type t = 
  match t with
  | Bool ->  "Bool"
  | Int  ->  "Int"
  | Rat  ->  "Rat"
  | Pointeur t -> "Pointeur(" ^ (string_of_type t) ^ ")"
  | Void -> "Void"
  | TypeEnum n -> "Enum(" ^ n ^ ")"
  | Undefined -> "Undefined"


let rec est_compatible t1 t2 =
  match t1, t2 with
  | Bool, Bool -> true
  | Int, Int -> true
  | Rat, Rat -> true
  | Void, Void -> true
  | Pointeur Undefined, Pointeur _ -> true
  | Pointeur _, Pointeur Undefined -> true
  | Pointeur t1', Pointeur t2' -> est_compatible t1' t2'
  | TypeEnum n1, TypeEnum n2 -> n1 = n2
  | _ -> false


let est_compatible_list lt1 lt2 =
  try
    List.for_all2 est_compatible lt1 lt2
  with Invalid_argument _ -> false


let rec getTaille t =
  match t with
  | Int -> 1
  | Bool -> 1
  | Rat -> 2
  | Pointeur _ -> 1
  | Void -> 0
  | TypeEnum _ -> 1  (* Enum = entier *)
  | Undefined -> 0

(* TESTS UNITAIRES : les types de base *)

(* Tests est_compatible - types simples *)
let%test _ = est_compatible Bool Bool
let%test _ = est_compatible Int Int
let%test _ = est_compatible Rat Rat
let%test _ = est_compatible Void Void
let%test _ = not (est_compatible Int Bool)
let%test _ = not (est_compatible Bool Int)
let%test _ = not (est_compatible Int Rat)
let%test _ = not (est_compatible Rat Int)
let%test _ = not (est_compatible Bool Rat)
let%test _ = not (est_compatible Rat Bool)
let%test _ = not (est_compatible Void Int)
let%test _ = not (est_compatible Int Void)

(* Tests est_compatible - Undefined *)
let%test _ = not (est_compatible Undefined Int)
let%test _ = not (est_compatible Int Undefined)
let%test _ = not (est_compatible Rat Undefined)
let%test _ = not (est_compatible Bool Undefined)
let%test _ = not (est_compatible Undefined Bool)
let%test _ = not (est_compatible Undefined Rat)
let%test _ = not (est_compatible Undefined Void)

(* Tests est_compatible - Pointeurs *)
let%test _ = est_compatible (Pointeur Int) (Pointeur Int)
let%test _ = est_compatible (Pointeur Bool) (Pointeur Bool)
let%test _ = est_compatible (Pointeur Rat) (Pointeur Rat)
let%test _ = est_compatible (Pointeur Void) (Pointeur Void)

(* Tests est_compatible - Null polymorphe *)
let%test _ = est_compatible (Pointeur Undefined) (Pointeur Int)
let%test _ = est_compatible (Pointeur Int) (Pointeur Undefined)
let%test _ = est_compatible (Pointeur Undefined) (Pointeur Bool)
let%test _ = est_compatible (Pointeur Bool) (Pointeur Undefined)
let%test _ = est_compatible (Pointeur Undefined) (Pointeur Rat)
let%test _ = est_compatible (Pointeur Rat) (Pointeur Undefined)
let%test _ = est_compatible (Pointeur Undefined) (Pointeur Void)
let%test _ = est_compatible (Pointeur Undefined) (Pointeur Undefined)

(* Tests est_compatible - Pointeurs incompatibles *)
let%test _ = not (est_compatible (Pointeur Int) (Pointeur Bool))
let%test _ = not (est_compatible (Pointeur Bool) (Pointeur Int))
let%test _ = not (est_compatible (Pointeur Int) (Pointeur Rat))
let%test _ = not (est_compatible (Pointeur Rat) (Pointeur Int))

(* Tests est_compatible - Pointeurs sur pointeurs *)
let%test _ = est_compatible (Pointeur (Pointeur Int)) (Pointeur (Pointeur Int))
let%test _ = est_compatible (Pointeur (Pointeur Undefined)) (Pointeur (Pointeur Int))
let%test _ = est_compatible (Pointeur (Pointeur Int)) (Pointeur (Pointeur Undefined))
let%test _ = not (est_compatible (Pointeur (Pointeur Int)) (Pointeur (Pointeur Bool)))

(* Tests est_compatible - Pointeur vs non-pointeur *)
let%test _ = not (est_compatible (Pointeur Int) Int)
let%test _ = not (est_compatible Int (Pointeur Int))
let%test _ = not (est_compatible (Pointeur Bool) Bool)
let%test _ = not (est_compatible Bool (Pointeur Bool))

(* Tests getTaille - types simples *)
let%test _ = getTaille Int = 1
let%test _ = getTaille Bool = 1
let%test _ = getTaille Rat = 2
let%test _ = getTaille Void = 0
let%test _ = getTaille Undefined = 0

(* Tests getTaille - pointeurs *)
let%test _ = getTaille (Pointeur Int) = 1
let%test _ = getTaille (Pointeur Bool) = 1
let%test _ = getTaille (Pointeur Rat) = 1
let%test _ = getTaille (Pointeur Void) = 1
let%test _ = getTaille (Pointeur (Pointeur Int)) = 1
let%test _ = getTaille (Pointeur (Pointeur (Pointeur Int))) = 1

(* Tests est_compatible_list - listes vides *)
let%test _ = est_compatible_list [] []

(* Tests est_compatible_list - listes compatibles *)
let%test _ = est_compatible_list [Int] [Int]
let%test _ = est_compatible_list [Int; Rat] [Int; Rat]
let%test _ = est_compatible_list [Bool; Rat; Bool] [Bool; Rat; Bool]
let%test _ = est_compatible_list [Int; Bool; Rat] [Int; Bool; Rat]

(* Tests est_compatible_list - listes avec pointeurs *)
let%test _ = est_compatible_list [Pointeur Int] [Pointeur Int]
let%test _ = est_compatible_list [Pointeur Undefined; Int] [Pointeur Int; Int]
let%test _ = est_compatible_list [Int; Pointeur Int] [Int; Pointeur Undefined]

(* Tests est_compatible_list - listes incompatibles *)
let%test _ = not (est_compatible_list [Int] [Int; Rat])
let%test _ = not (est_compatible_list [Int; Rat] [Int])
let%test _ = not (est_compatible_list [Int] [Rat; Int])
let%test _ = not (est_compatible_list [Int; Rat] [Rat; Int])
let%test _ = not (est_compatible_list [Bool; Rat; Bool] [Bool; Rat; Bool; Int])
let%test _ = not (est_compatible_list [Int; Bool] [Int; Rat])
let%test _ = not (est_compatible_list [Pointeur Int] [Pointeur Bool])

(* Tests Enum *)
let%test _ = est_compatible (TypeEnum "Couleur") (TypeEnum "Couleur")
let%test _ = not (est_compatible (TypeEnum "Couleur") (TypeEnum "Jour"))
let%test _ = not (est_compatible (TypeEnum "Couleur") Int)
let%test _ = not (est_compatible Int (TypeEnum "Couleur"))
let%test _ = getTaille (TypeEnum "Test") = 1
let%test _ = getTaille (Pointeur Int) = 1
let%test _ = getTaille (Pointeur (TypeEnum "Test")) = 1

(* Tests est_compatible_list *)
let%test _ = est_compatible_list [] []
let%test _ = est_compatible_list [Int; Bool] [Int; Bool]
let%test _ = est_compatible_list [TypeEnum "A"; Int] [TypeEnum "A"; Int]
let%test _ = not (est_compatible_list [TypeEnum "A"] [TypeEnum "B"])
let%test _ = not (est_compatible_list [Int] [TypeEnum "A"])
