open List

type token = 
  | UL_RIGHT_BRACE
  | UL_PACKAGE
  | UL_LEFT_BRACE
  | UL_PACKAGE_IDENT of (string)
    | UL_FIN
    | UL_ERREUR;;
  | UL_INTERFACE
  | UL_EXTENDS
  |UL_VOID
  |UL_POINT_VIR
  |UL_POINT
  |UL_VIR
  |UL_RIGHT_PAR
  | UL_LEFT_PAR
  |UL_BOOLEAN
  |UL_INT
  
type inputStream = token list;;

(* string_of_token : token -> string *)
(* Converti un token en une chaîne de caractère*)
let string_of_token token =
     match token with
       | UL_LEFT_BRACE -> "{"
       | UL_RIGHT_BRACE -> "}"
       | UL_PACKAGE -> "package"
       | UL_PACKAGE_IDENT n -> n
       | UL_FIN -> "EOF"
       | UL_ERREUR -> "Erreur Lexicale";;
      | UL_INTERFACE -> "interface"
      | UL_EXTENDS -> "extends"
      |UL_VOID-> "void"
      |UL_POINT_VIR -> ";"
      |UL_POINT -> "."
      |UL_VIR -> ","
      |UL_RIGHT_PAR -> "("
      | UL_LEFT_PAR -> ")"
      |UL_BOOLEAN -> "boolean"
      |UL_INT -> "int"
  

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
