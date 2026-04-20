%{

(* Partie recopiee dans le fichier CaML genere. *)
(* Ouverture de modules exploites dans les actions *)
(* Declarations de types, de constantes, de fonctions, d'exceptions exploites dans les actions *)

(* let nbrVariables = ref 0;; *)

let nbrFonctions = ref 0;;

%}

/* Declaration des unites lexicales et de leur type si une valeur particuliere leur est associee */

%token IMPORT
%token <string> IDENT TYPEIDENT
%token INT FLOAT BOOL CHAR VOID STRING
%token ACCOUV ACCFER PAROUV PARFER CROOUV CROFER
%token PTVIRG VIRG
%token SI SINON TANTQUE RETOUR
/* Defini le type des donnees associees a l'unite lexicale */
%token <int> ENTIER
%token <float> FLOTTANT
%token <bool> BOOLEEN
%token <char> CARACTERE
%token <string> CHAINE
%token VIDE
%token NOUVEAU
%token ASSIGN
%token OPINF OPSUP OPINFEG OPSUPEG OPEG OPNONEG
%token OPPLUS OPMOINS OPOU
%token OPMULT OPMOD OPDIV OPET
%token OPNON
%token OPPT
/* Unite lexicale particuliere qui represente la fin du fichier */
%token FIN

/* Declarations des regles d'associative et de priorite pour les operateurs */
/* La priorite est croissante de haut en bas */
/* Associatif a droite */
%right ASSIGN /* Priorite la plus faible */
/* Non associatif */
%nonassoc OPINF OPSUP OPINFEG OPSUPEG OPEG OPNONEG
/* Associatif a gauche */
%left OPPLUS OPMOINS OPOU
%left OPMULT OPMOD OPDIV OPET
%right OPNON
%left OPPT PAROUV CROOUV /* Priorite la plus forte */

/* Type renvoye pour le nom terminal fichier */
%type <unit> fichier
%type <int> variables

/* Le non terminal fichier est l'axiome */
%start fichier

%% /* Regles de productions */

fichier : programme FIN { (print_endline "fichier : programme FIN");(print_string "Nombre de fonctions : ");(print_int !nbrFonctions);(print_newline()) }

programme : /* Lambda, mot vide */ { (nbrFonctions := 0); (print_endline "programme : /* Lambda, mot vide */") }
          | fonction programme { (nbrFonctions := !nbrFonctions + 1);(print_endline "programme : fonction programme") }

typeStruct : typeBase declTab { (print_endline "typeStruct : typeBase declTab") }

typeBase : INT { (print_endline "typeBase : INT") }
         | FLOAT { (print_endline "typeBase : FLOAT") }
         | BOOL { (print_endline "typeBase : BOOL") }
         | CHAR { (print_endline "typeBase : CHAR") }
         | STRING { (print_endline "typeBase : STRING") }
         | TYPEIDENT { (print_endline "typeBase : TYPEIDENT") }

declTab : /* Lambda, mot vide */ { (print_endline "declTab : /* Lambda, mot vide */") }
        | CROOUV CROFER { (print_endline "declTab : CROOUV CROFER") }

fonction : entete bloc  { (print_endline "fonction : entete bloc") }

entete : typeStruct IDENT PAROUV parsFormels PARFER { (print_endline "entete : typeStruct IDENT PAROUV parsFormels PARFER") }
       | VOID IDENT PAROUV parsFormels PARFER { (print_endline "entete : VOID IDENT PAROUV parsFormels PARFER") }

parsFormels : /* Lambda, mot vide */ { (print_endline "parsFormels : /* Lambda, mot vide */") }
            | typeStruct IDENT suiteParsFormels { (print_endline "parsFormels : typeStruct IDENT suiteParsFormels") }

suiteParsFormels : /* Lambda, mot vide */ { (print_endline "suiteParsFormels : /* Lambda, mot vide */") }
                 | VIRG typeStruct IDENT suiteParsFormels { (print_endline "suiteParsFormels : VIRG typeStruct IDENT suiteParsFormels") }

bloc : ACCOUV /* $1 */ variables /* $2 */ instructions /* $3 */ ACCFER /* $4 */
     {
	(print_endline "bloc : ACCOUV variables instructions ACCFER");
	(print_string "Nombre de variables = ");
	(print_int $2);
	(print_newline ())
	}

variables : /* Lambda, mot vide */
	  {
		(print_endline "variables : /* Lambda, mot vide */");
		0
		}
          | variable /* $1 */ variables /* $2 */
	  {
		(print_endline "variables : variable variables");
		($2 + 1)
		}

variable : typeStruct IDENT PTVIRG { (print_endline "variable : typeStruct IDENT PTVIRG") }

/* A FAIRE : Completer pour decrire une liste d'instructions eventuellement vide */
instructions :  /* Lambda, mot vide */  { (print_endline "instructions : instruction vide") }
				| instruction { (print_endline "instructions : instruction") }

/* A FAIRE : Completer pour ajouter les autres formes d'instructions */
               instruction : expression PTVIRG { (print_endline "instruction : expression PTVIRG") }
                             | RETOUR expression PTVIRG  { (print_endline "instruction : RETURN expression PTVIRG") }
							 | SI PAROUV expression PARFER bloc { (print_endline "instruction : SI PAROUV expression PARFER bloc") }
							 | SI PAROUV expression PARFER bloc SINON bloc { (print_endline "instruction : SI PAROUV expression PARFER bloc SINON bloc") }
							 | TANTQUE PAROUV expression PARFER bloc { (print_endline "instruction : TANTQUE PAROUV expression PARFER bloc") }

/* A FAIRE : Completer pour ajouter les autres formes d'expressions */
unaire : PAROUV typeStruct PARFER { (print_endline "unaire : PAROUV typeStruct PARFER") }
		| OPPLUS { (print_endline "unaire : OPPLUS") }
		| OPMOINS { (print_endline "unaire : OPMOINS") }
		| OPNON { (print_endline "unaire : OPNON") }

expression_vals : ENTIER { (print_endline "expression_vals : ENTIER") }
				| FLOAT { (print_endline "expression_vals : FLOAT") }
				| CHAR { (print_endline "expression_vals : CHAR") }
				| BOOL { (print_endline "expression_vals : BOOL") }
				| VIDE { (print_endline "expression_vals : VIDE") }
				| NOUVEAU IDENT PAROUV PARFER { (print_endline "expression_vals : NOUVEAU IDENT PAROUV PARFER") }
				| NOUVEAU IDENT CROOUV expression CROFER { (print_endline "expression_vals : NOUVEAU IDENT CROOUV expression CROFER") }
				| IDENT suffixe_boucle { (print_endline "expression_vals : IDENT suffixe_boucle") }
				| PAROUV expression PARFER suffixe_boucle { (print_endline "expression_vals : PAROUV expression PARFER suffixe_boucle") }

suffixe_boucle : /* Suffixe vide*/ { (print_endline "suffixe_boucle : boucle vide") }
				| suffixe suffixe_boucle { (print_endline "suffixe_boucle : boucle vide") }

suffixe : CROOUV expression CROFER { (print_endline "suffixe : CROOUV expression CROFER ") }
		 | PAROUV PARFER { (print_endline "suffixe : PAROUV PARFER") }
		 | PAROUV expression expr_boucle PARFER { (print_endline "suffixe : PAROUV expression expr_boucle PARFER") }

expr_boucle : /* boucle vide*/ { (print_endline "expr_boucle : boucle vide") }
			| VIRG expression { (print_endline "expr_boucle : VIRG expression") }

expression_unit : unaire_boucle expression_vals { (print_endline "expression_unit : unaire_boucle expression_vals") }

unaire_boucle : /*unaire vide*/{ (print_endline "unaire_boucle : boucle vide") }
			| unaire { (print_endline "unaire_boucle : VIRG expression") } 


expression : expression_unit binaire_boucle { (print_endline "expression : expression_unit binaire_boucle") }

binaire_boucle : /*binaire boucle vide*/{ (print_endline "biaire_boucle : boucle vide") }
				|binaire expression binaire_boucle { (print_endline "biaire_boucle : binaire expression binaire_boucle") }

binaire : ASSIGN { (print_endline "assign") }
		| OPPT { (print_endline "oppt") }
		| OPPLUS { (print_endline "opplus") }
		| OPMOINS { (print_endline "opmoins") }
		| OPMULT { (print_endline "opmult") }
		| OPDIV { (print_endline "opdiv") }
		| OPMOD { (print_endline "opmod") }
		| OPOU { (print_endline "opou") }
		| OPET { (print_endline "opet") }
		| OPEG { (print_endline "opeg") }
		| OPNONEG { (print_endline "opnoneg") }
		| OPINF { (print_endline "opinf") }
		| OPSUP	{ (print_endline "opsup") }
		| OPINFEG { (print_endline "opinfeq") }
		| OPSUPEG { (print_endline "opsupeq") }

%%