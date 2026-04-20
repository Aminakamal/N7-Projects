%{

(* Partie recopiee dans le fichier CaML genere. *)
(* Ouverture de modules exploites dans les actions *)
(* Declarations de types, de constantes, de fonctions, d'exceptions exploites dans les actions *)

%}

/* Declaration des unites lexicales et de leur type si une valeur particuliere leur est associee */

%token UL_PACKAGE
%token UL_LEFT_BRACE UL_RIGHT_BRACE
%token UL_EXTENDS
%token UL_INTERFACE
%token UL_INT
%token UL_BOOLEAN
%token UL_VOID
%token UL_LEFT_PAR
%token UL_RIGHT_PAR
%token UL_POINT_VIR
%token UL_VIR
%token UL_POINT

/* Defini le type des donnees associees a l'unite lexicale */

%token <string> UL_IDENT_PACKAGE
%token <string> UL_IDENT_INTERFACE

/* Unite lexicale particuliere qui represente la fin du fichier */

%token UL_FIN

/* Type renvoye pour le nom terminal document */
%type <unit> package

/* Le non terminal document est l'axiome */
%start package

%% /* Regles de productions */

package : internal_package UL_FIN { (print_endline "package : internal_package FIN") }

internal_package : UL_PACKAGE UL_IDENT_PACKAGE UL_LEFT_BRACE internal_package boucle_package UL_RIGHT_BRACE { (print_endline "package : package IDENT_PACKAGE { package }") }
                    |UL_PACKAGE UL_IDENT_PACKAGE UL_LEFT_BRACE interface boucle_package UL_RIGHT_BRACE { (print_endline "package : package IDENT_PACKAGE { interface }") }

boucle_package :  /* vide */ {(print_endline "vide")}
                    |internal_package boucle_package{ (print_endline "package")}
                    | interface boucle_package{ (print_endline "interface")}
interface : UL_INTERFACE UL_IDENT_INTERFACE UL_LEFT_BRACE boucle_methode UL_RIGHT_BRACE {(print_endline "interface : interface IDENT_INTERACE { boucle_methode }")}
                    |UL_INTERFACE UL_IDENT_INTERFACE UL_EXTENDS nom_qualifie boucle_v UL_LEFT_BRACE boucle_methode UL_RIGHT_BRACE {(print_endline "interface : interface IDENT_INTERACE extends nom_qualifie boucle_v { boucle_methode }")}
boucle_v : /*vide*/ {(print_endline "vide")}
          | UL_VIR nom_qualifie boucle_v {(print_endline "virgule nom_qualifie boucle_v")}
boucle_methode : /*vide */  {(print_endline "vide")}
                | methode boucle_methode {(print_endline "methode boucle_methode")}
nom_qualifie : boucle_ident UL_IDENT_INTERFACE {(print_endline  "nom_qualifie : boucle_ident IDENT_INTERFACE")}
boucle_ident :/*vide*/ {(print_endline "vide")}
              | UL_IDENT_PACKAGE UL_POINT boucle_ident {(print_endline " IDENT_PACKAGE POINT boucle_ident")}
methode : types UL_IDENT_PACKAGE UL_LEFT_PAR UL_RIGHT_PAR UL_POINT_VIR {(print_endline " methode : IDENT_PACKaGE LRFT_PAR RIGHT_PAR POINT_VIR")}
         |types UL_IDENT_PACKAGE UL_LEFT_PAR types boucle_type UL_RIGHT_PAR UL_POINT_VIR {(print_endline " methode : IDENT_PACKaGE LRFT_PAR type boucle_type RIGHT_PAR POINT_VIR")}
boucle_type : /*vide*/ {(print_endline "vide")}
            | UL_VIR types boucle_type {(print_endline "boucle_type : VIR type boucle_type")}
types : UL_BOOLEAN {(print_endline "type : BOOLEAN ")}
      | UL_INT {(print_endline "type : INT")}
      | UL_VOID {(print_endline "type : VOID")}
      |nom_qualifie {(print_endline "type : nom_qualifie")}


%%

