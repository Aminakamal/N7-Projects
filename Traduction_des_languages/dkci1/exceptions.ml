open Type
open Ast.AstSyntax

(* Exceptions pour la gestion des identificateurs *)
exception DoubleDeclaration of string 
exception IdentifiantNonDeclare of string 
exception MauvaiseUtilisationIdentifiant of string 

(* Exceptions pour le typage *)
exception TypeInattendu of typ * typ
exception TypesParametresInattendus of typ list * typ list
exception TypeBinaireInattendu of binaire * typ * typ

(* Exceptions pour les affectables *)
exception AffectableInvalide of string
exception DerefNonPointeur of typ

(* Exceptions pour l'affichage *)
exception AffichageTypeInvalide of typ

(* Exceptions pour les procédures *)
exception RetourDansMain
exception RetourAvecValeurDansVoid
exception RetourVideDansNonVoid of typ
exception AppelFonctionCommeProc of string * typ

(* Exception pour passage par référence *)
exception ParametreRefIncorrect of string

(* Exceptions pour les enums *)
exception DoubleDeclarationEnum of string
exception ValeurEnumDejaDeclare of string * string  (* valeur, type1 *)
exception TypeEnumInconnu of string
exception ValeurEnumInconnue of string

(* Erreur interne du compilateur *)
exception ErreurInterne of string