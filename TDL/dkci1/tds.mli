open Type 

(* Définition du type des informations associées aux identifiants *)
type info =
  | InfoConst of string * int
  | InfoVar of string * typ * int * string * bool
  | InfoFun of string * typ * (typ * bool) list
  | InfoTypeEnum of string * string list
  | InfoValeurEnum of string * string * int

(* Table des symboles *)
type tds 

(* Données stockées dans la tds et dans les AST : pointeur sur une information *)
type info_ast

(* Création d'une table des symboles à la racine *)
val creerTDSMere : unit -> tds 

(* Création d'une table des symboles fille *)
val creerTDSFille : tds -> tds 

(* Ajoute une information dans la table des symboles locale *)
val ajouter : tds -> string -> info_ast -> unit 

(* Recherche les informations d'un identificateur dans la tds locale *)
val chercherLocalement : tds -> string -> info_ast option 

(* Recherche les informations d'un identificateur dans la tds globale *)
val chercherGlobalement : tds -> string -> info_ast option 

(* Affiche la tds locale *)
val afficher_locale : tds -> unit 

(* Affiche la tds locale et récursivement *)
val afficher_globale : tds -> unit 

(* Créer une information à associer à l'AST à partir d'une info *)
val info_to_info_ast : info -> info_ast

(* Récupère l'information associée à un noeud *)
val info_ast_to_info : info_ast -> info

(* Modifie le type si c'est une InfoVar *)
val modifier_type_variable : typ -> info_ast -> unit

(* Modifie les types de retour et des paramètres si c'est une InfoFun *)
val modifier_type_fonction : typ -> (typ * bool) list -> info_ast -> unit

(* Modifie l'emplacement si c'est une InfoVar *)
val modifier_adresse_variable : int -> string -> info_ast -> unit