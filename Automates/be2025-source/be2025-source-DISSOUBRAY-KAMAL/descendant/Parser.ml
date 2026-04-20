open Tokens

(* Type du résultat d'une analyse syntaxique *)
type parseResult =
  | Success of inputStream
  | Failure
;;
let acceptTERMINAL stream =
  match (peekAtFirstToken stream) with
    | (UL_TERMINAL name) -> (print_endline ("accept " ^ name));(Success (advanceInStream stream))
    | _ -> Failure
;;
let acceptNonTERMINAL stream =
  match (peekAtFirstToken stream) with
    | (UL_NON_TERMINAL name) -> (print_endline ("accept " ^ name));(Success (advanceInStream stream))
    | _ -> Failure
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
let rec parseL stream =
    (print_string "L->");
  (match(peekAtFirstToken stream) with
  |UL_LEFT_BRACE|UL_LEFT_CRO|UL_LEFT_PAR|UL_NON_TERMINAL _|UL_TERMINAL _ -> 
    ((inject stream)>>= 
    parseE >>=
    parseL)
  |UL_OP|UL_POINT|UL_RIGHT_BRACE|UL_RIGHT_CRO|UL_RIGHT_PAR -> inject stream
  |_ -> Failure)

and parseP stream =
  (print_string "P -> L S");
  (match(peekAtFirstToken stream) with
    |UL_OP | UL_POINT | UL_RIGHT_PAR|UL_RIGHT_BRACE|UL_RIGHT_CRO|UL_LEFT_BRACE|UL_LEFT_CRO|UL_LEFT_PAR|UL_NON_TERMINAL _|UL_TERMINAL _ ->
      ((inject stream) >>=
      parseL >>=
      parseS)
    | _ -> Failure
  )
and parseR stream =
  (print_string "R-> Non terminal ::= P");
  (match (peekAtFirstToken stream) with
    |UL_NON_TERMINAL _->
      ((inject stream)>>=
        (acceptNonTERMINAL)>>=
        (accept UL_DERIV)>>=
        parseP)
    |_ -> Failure)
    
(* parseG : inputStream -> parseResult *)
(* Analyse du non terminal Programme *)
and rec parseG stream =
  (print_string "G -> ");
  (match (peekAtFirstToken stream) with
    |UL_NON_TERMINAL _  ->
    (print_endline "NON_TERMINAl { ... }");
      ((inject stream) >>=
      parseR >>=
      parseG )
    |UL_DOLLAR -> inject stream

    | _ -> Failure)


and rec parseS stream =
  (print_string "S->");
  (match(peekAtFirstToken stream) with
    |UL_OP ->
      ((inject stream)>>=
        (accept UL_OP)>>=
        parseL>>=
        parseS)
    |UL_POINT |UL_RIGHT_PAR |UL_RIGHT_BRACE |UL_RIGHT_CRO -> inject stream
    |_ -> Failure

  ) 
  

and parseE stream =
    (print_string "E->");
  (match(peekAtFirstToken stream) with
  |UL_LEFT_PAR -> 
    ((inject stream)>>= 
     (accept UL_LEFT_PAR)>>=
     parseP>>=
     (accept UL_RIGHT_PAR))
  |UL_LEFT_CRO  ->
    ((inject stream)>>= 
     (accept UL_LEFT_CRO)>>=
     parseP>>=
     (accept UL_RIGHT_CRO))
  |UL_LEFT_BRACE ->
    ((inject stream)>>= 
     (accept UL_LEFT_BRACE)>>=
     parseP>>=
     (accept UL_RIGHT_BRACE))
  |UL_NON_TERMINAL _->
    ((inject stream)>>= 
      (acceptNonTERMINAL))
  |UL_TERMINAL _ ->
    ((inject stream)>>= 
      (acceptTERMINAL))
  |_ -> Failure
  )
  
;;
