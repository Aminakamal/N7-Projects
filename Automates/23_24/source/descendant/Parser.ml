open Tokens

(* Type du résultat d'une analyse syntaxique *)
type parseResult =
  | Success of inputStream
  | Failure
;;

(* accept : token -> inputStream -> parseResult *)
(* Vérifie que le premier token du flux d'entrée est bien le token attendu *)
(* et avance dans l'analyse si c'est le cas *)
let accept expected stream =
  match (peekAtFirstToken stream) with
    | token when (token = expected) ->
      (Success (advanceInStream stream))
    | _ -> Failure
;;

(* accept : token -> inputStream -> parseResult *)
(* Vérifie que le premier token du flux d'entrée est bien le token attendu *)
(* et avance dans l'analyse si c'est le cas *)
let acceptPackageIdent stream =
  match (peekAtFirstToken stream) with
    | UL_PACKAGE_IDENT _ ->
      (Success (advanceInStream stream))
    | _ -> Failure
;;

(* Définition de la monade  qui est composée de : *)
(* - le type de donnée monadique : parseResult  *)
(* - la fonction : inject qui construit ce type à partir d'une liste de terminaux *)
(* - la fonction : bind (opérateur >>=) qui combine les fonctions d'analyse. *)

(* inject inputStream -> parseResult *)
(* Construit le type de la monade à partir d'une liste de terminaux *)
let inject s = Success s;;

(* bind : 'a m -> ('a -> 'b m) -> 'b m *)
(* bind (opérateur >>=) qui combine les fonctions d'analyse. *)
(* ici on utilise une version spécialisée de bind :
   'b  ->  inputStream
   'a  ->  inputStream
    m  ->  parseResult
*)
(* >>= : parseResult -> (inputStream -> parseResult) -> parseResult *)
let (>>=) result f =
  match result with
    | Success next -> f next
    | Failure -> Failure
;;


(* parseMachine : inputStream -> parseResult *)
(* Analyse du non terminal Programme *)
let (* rec *) parsePackage stream =
  (print_string "Package -> ");
  (match (peekAtFirstToken stream) with
   | UL_PACKAGE ->
      (print_endline "package UL_IDENT_PACKAGE { ... }");
      ((inject stream) >>=
        (accept UL_PACKAGE) >>=
        acceptPackageIdent >>=
        (accept UL_LEFT_BRACE) >>=
        parseE >>=
        parseSE >>=
        (accept UL_RIGHT_BRACE))
   | _ -> Failure)
let rec parseSE stream =
    (print_string "SE-> ");
    (match (peekAtFirstToken stream) with
    |UL_RIGHT_BRACE -> inject stream 
    | UL_PACKAGE | UL_INTERFACE -> 
            ((inject stream) >>=
              parseE >>=
              parseSE )
    | _ -> Failure 
    )
let parseE stream =
  (match (peekAtFirstToken stream) with 
  |UL_PACKAGE -> 
    ((inject stream) >>=
    parsePackage)
  |UL_INTERFACE -> 
    ((inject stream) >>= 
    parseI)
    | _ -> Failure      
  )
let parseI  stream =
  (match (peekAtFirstToken stream) with 
  |UL_INTERFACE -> 
       ((inject stream) >>=
       (accept UL_INTERFACE
;;
