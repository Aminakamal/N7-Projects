{

(* Partie recopiée dans le fichier CaML généré. *)
(* Ouverture de modules exploités dans les actions *)
(* Déclarations de types, de constantes, de fonctions, d'exceptions exploités dans les actions *)

  open Parser 
  exception LexicalError

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

rule lexer = parse
  | ['\n' '\t' ' ']+					{ (lexer lexbuf) }
  | commentaire						{ (lexer lexbuf) }
  | "{"                   {UL_LEFT_BRACE}
  | "}"                    {UL_RIGHT_BRACE}
  | "("                    {UL_LEFT_PAR}
  | ")"                    {UL_RIGHT_PAR}
  | "["                    {UL_LEFT_CRO}
  | "]"                    {UL_RIGHT_CRO}
  | "::="                  {UL_DERIV}
  |"."                      {UL_POINT}
  | "|"                     {UL_OP}
  | majuscule alphanum* as name  {UL_TERMINAL name} 
  | "<" minuscule alphanum* ">" as name   {UL_NON_TERMINAL name}
  | eof							{ UL_DOLLAR }
  | _ as texte				 		{ (print_string "Erreur lexicale : ");(print_char texte);(print_newline ()); raise LexicalError }

{

}
