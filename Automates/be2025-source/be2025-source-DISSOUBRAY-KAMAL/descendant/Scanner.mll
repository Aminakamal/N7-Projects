{

(* Partie recopiée dans le fichier CaML généré. *)
(* Ouverture de modules exploités dans les actions *)
(* Déclarations de types, de constantes, de fonctions, d'exceptions exploités dans les actions *)

  open Tokens 
  exception Printf

}

(* Déclaration d'expressions régulières exploitées par la suite *)
let chiffre = ['0' - '9']
let minuscule = ['a' - 'z']
let majuscule = ['A' - 'Z']
let alphabet = minuscule | majuscule
let alphanum = alphabet | chiffre | '_'
let commentaire =
  (* Commentaire fin de ligne *)
  "#" [^'\n']*

rule scanner = parse
  | ['\n' '\t' ' ']+					{ (scanner lexbuf) }
  | commentaire						{ (scanner lexbuf) }
   | "{"                   {UL_LEFT_BRACE::(scanner lexbuf)}
  | "}"                    {UL_RIGHT_BRACE::(scanner lexbuf)}
  | "("                    {UL_LEFT_PAR::(scanner lexbuf)}
  | ")"                    {UL_RIGHT_PAR::(scanner lexbuf)}
  | "["                    {UL_LEFT_CRO::(scanner lexbuf)}
  | "]"                    {UL_RIGHT_CRO::(scanner lexbuf)}
  | "::="                  {UL_DERIV::(scanner lexbuf)}
  |"."                      {UL_POINT::(scanner lexbuf)}
  | "|"                     {UL_OP::(scanner lexbuf)}
  | majuscule alphanum* as name  {UL_TERMINAL name ::(scanner lexbuf) } 
  | "<" minuscule alphanum* ">" as name   {UL_NON_TERMINAL name ::(scanner lexbuf) }
  | eof							{ [UL_DOLLAR] }
  | _ as texte				 		{ (print_string "Erreur lexicale : ");(print_char texte);(print_newline ()); (UL_ERREUR::(scanner lexbuf)) }

{

}
