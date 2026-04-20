open List

type token =
    (* A COMPLETER *)
    | UL_DOLLAR
    | UL_ERREUR
    |UL_LEFT_BRACE
    |UL_RIGHT_BRACE
    |UL_LEFT_PAR
    |UL_RIGHT_PAR
    |UL_LEFT_CRO
    |UL_RIGHT_CRO
    |UL_DERIV
    |UL_POINT
    |UL_OP
    | UL_TERMINAL of string
    | UL_NON_TERMINAL of string ;;

type inputStream = token list;;

(* string_of_token : token -> string *)
(* Converti un token en une chaîne de caractère*)
let string_of_token token =
     match token with
       (* A COMPLETER *)
      | UL_DOLLAR -> "EOF"
      | UL_ERREUR -> "Erreur Lexicale"
      |UL_LEFT_BRACE -> "{"
      |UL_RIGHT_BRACE ->"}"
      |UL_LEFT_PAR -> "("
      |UL_RIGHT_PAR ->")"
      |UL_LEFT_CRO ->"["
      |UL_RIGHT_CRO ->"]"
      |UL_DERIV ->"::="
      |UL_POINT ->"."
      |UL_OP -> "|"
      | UL_TERMINAL n -> n
      | UL_NON_TERMINAL n -> n
    ;;

(* string_of_stream : inputStream -> string *)
(* Converti un inputStream (liste de token) en une chaîne de caractère *)
let string_of_stream stream =
  List.fold_right (fun t tq -> (string_of_token t) ^ " " ^ tq ) stream "";;


(* peekAtFirstToken : inputStream -> token *)
(* Renvoie le premier élément d'un inputStream *)
(* Erreur : si l'inputStream est vide *)
let peekAtFirstToken stream = 
  match stream with
  (* Normalement, ne doit jamais se produire sauf si la grammaire essaie de lire *)
  (* après la fin de l'inputStream. *)
  | [] -> failwith "Impossible d'acceder au premier element d'un inputStream vide"
   |t::_ -> t;;

(* advanceInStream : inputStream -> inputStream *)
(* Consomme le premier élément d'un inputStream *)
(* Erreur : si l'inputStream est vide *)
let advanceInStream stream =
  match stream with
  (* Normalement, ne doit jamais se produire sauf si la grammaire essaie de lire *)
  (* après la fin de l'inputStream. *)
  | [] -> failwith "Impossible de consommer le premier element d'un inputStream vide"
  | _::q -> q;;
