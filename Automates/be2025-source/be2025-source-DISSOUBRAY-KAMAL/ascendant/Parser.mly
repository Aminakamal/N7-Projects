%{

(* Partie recopiee dans le fichier CaML genere. *)
(* Ouverture de modules exploites dans les actions *)
(* Declarations de types, de constantes, de fonctions, d'exceptions exploites dans les actions *)

%}

/* Declaration des unites lexicales et de leur type si une valeur particuliere leur est associee */

%token UL_LEFT_BRACE
%token UL_RIGHT_BRACE
%token UL_LEFT_PAR
%token UL_RIGHT_PAR
%token UL_LEFT_CRO
%token UL_RIGHT_CRO
%token UL_DERIV
%token UL_POINT
%token UL_OP
/* Defini le type des donnees associees a l'unite lexicale */

%token <string>UL_TERMINAL
%token <string>UL_NON_TERMINAL

/* Unite lexicale particuliere qui represente la fin du fichier */

%token UL_DOLLAR

/* Type renvoye pour le nom terminal document */
%type <unit> grammaire

/* Le non terminal document est l'axiome */
%start grammaire

%% /* Regles de productions */

grammaire : internal_grammaire UL_DOLLAR { (* A COMPLETER *) (print_endline "grammaire : ...") }
internal_grammaire: UL_NON_TERMINAL UL_DERIV production UL_POINT boucle_gram {(print_endline "internal_grammaire : NON_TERMINAL DERIV production POINT")}
boucle_gram : /*vide*/ {(print_endline "vide")}
             |  UL_NON_TERMINAL UL_DERIV production UL_POINT boucle_gram {(print_endline "boucle_gram : NON_TERMINAL DERIV production POINT")}
production : contenu_prod boucle_retour_prod{(print_endline "contenu_prod boucle_retour_prod")}


contenu_prod: UL_NON_TERMINAL {(print_endline "non_terminal")}
            | UL_TERMINAL {(print_endline "terminal")}
            | UL_LEFT_CRO production UL_RIGHT_CRO {(print_endline "Left_Cro production Right_Cro")}
            | UL_LEFT_BRACE production UL_RIGHT_BRACE {(print_endline "Left_Brace production Right_Brace")}
            | UL_LEFT_PAR production UL_RIGHT_PAR {(print_endline "Left_Par production Right_Par")}

boucle_retour_prod : /*vide*/{(print_endline "vide")}
                    |UL_OP contenu_prod boucle_retour_prod{(print_endline "OP boucle_prod")}
                    | contenu_prod boucle_retour_prod {(print_endline "boucle_prod")}



%%              
