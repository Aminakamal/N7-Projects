(* Module de la passe de génération de code *)
open Tds
open Ast
open Code
open Tam
open Type

type t1 = Ast.AstPlacement.programme
type t2 = string

(* analyse_code_expression : AstPlacement.expression -> string *)
(* Paramètre e : l'expression à analyser *)
(* Génère le code TAM pour évaluer l'expression *)
(* Le résultat est laissé au sommet de la pile *)
let rec analyse_code_expression e =
  match e with
  | AstType.AppelFonction (info, le) ->
      begin
        match info_ast_to_info info with
        | InfoFun (nom, _, _) ->
            (* On force l'ordre d'évaluation de gauche à droite pour empiler les paramètres *)
            (* car l'ordre d'évaluation par défaut d'OCaml n'est pas garanti [cite: 10, 18] *)
            let code_params = List.fold_left (fun acc e -> acc ^ (analyse_code_expression e)) "" le in
            code_params ^ (call "ST" nom)
        | _ -> failwith "Internal error: AppelFonction sans InfoFun"
      end
  
  | AstType.Ident info ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, t, depl, reg) ->
            (* Charger la variable depuis la mémoire [cite: 137] *)
            load (getTaille t) depl reg
        | InfoConst (_, v) ->
            (* Charger la constante [cite: 137] *)
            loadl_int v
        | _ -> failwith "Internal error: Ident sans InfoVar/InfoConst"
      end
  
  | AstType.Booleen b ->
      if b then loadl_int 1 else loadl_int 0
  
  | AstType.Entier i ->
      loadl_int i
  
  | AstType.Unaire (op, e1) ->
      let code_e1 = analyse_code_expression e1 in
      begin
        match op with
        | AstType.Numerateur ->
            code_e1 ^ (pop 0 1)  (* On garde le numérateur (1er mot), on dépile le dénominateur *)
        | AstType.Denominateur ->
            code_e1 ^ (pop 1 1)  (* On garde le dénominateur (2ème mot), on dépile le numérateur *)
      end
  
  | AstType.Binaire (op, e1, e2) ->
      let code_e1 = analyse_code_expression e1 in
      let code_e2 = analyse_code_expression e2 in
      begin
        match op with
        | AstType.Fraction ->
            code_e1 ^ code_e2 ^ (call "ST" "norm")
        | AstType.PlusInt ->
            code_e1 ^ code_e2 ^ (subr "IAdd")
        | AstType.PlusRat ->
            code_e1 ^ code_e2 ^ (call "ST" "RAdd")
        | AstType.MultInt ->
            code_e1 ^ code_e2 ^ (subr "IMul")
        | AstType.MultRat ->
            code_e1 ^ code_e2 ^ (call "ST" "RMul")
        | AstType.EquInt ->
            code_e1 ^ code_e2 ^ (subr "IEq")
        | AstType.EquBool ->
            code_e1 ^ code_e2 ^ (subr "IEq")
        | AstType.Inf ->
            code_e1 ^ code_e2 ^ (subr "ILss")
      end

(* analyse_code_instruction : AstPlacement.instruction -> string *)
(* Paramètre i : l'instruction à analyser *)
let rec analyse_code_instruction i =
  match i with
  | AstPlacement.Declaration (info, e) ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, t, depl, reg) ->
            let taille = getTaille t in
            let code_e = analyse_code_expression e in
            (* PUSH réserve l'espace, puis on calcule, puis on STORE *)
            (push taille) ^ code_e ^ (store taille depl reg)
        | _ -> failwith "Internal error: Declaration sans InfoVar"
      end
  
  | AstPlacement.Affectation (info, e) ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, t, depl, reg) ->
            let taille = getTaille t in
            let code_e = analyse_code_expression e in
            code_e ^ (store taille depl reg)
        | _ -> failwith "Internal error: Affectation sans InfoVar"
      end
  
  | AstPlacement.AffichageInt e ->
      (analyse_code_expression e) ^ (subr "IOut")
  
  | AstPlacement.AffichageRat e ->
      (analyse_code_expression e) ^ (call "ST" "ROut")
  
  | AstPlacement.AffichageBool e ->
      (analyse_code_expression e) ^ (subr "BOut")
  
  | AstPlacement.Conditionnelle (c, bt, be) ->
      let label_else = getEtiquette () in
      let label_fin = getEtiquette () in
      (analyse_code_expression c) ^
      (jumpif 0 label_else) ^
      (analyse_code_bloc bt) ^
      (jump label_fin) ^
      (label label_else) ^
      (analyse_code_bloc be) ^
      (label label_fin)
  
  | AstPlacement.TantQue (c, b) ->
      let label_debut = getEtiquette () in
      let label_fin = getEtiquette () in
      (label label_debut) ^
      (analyse_code_expression c) ^
      (jumpif 0 label_fin) ^
      (analyse_code_bloc b) ^
      (jump label_debut) ^
      (label label_fin)
  
  | AstPlacement.Retour (e, taille_ret, taille_params) ->
      let code_e = analyse_code_expression e in
      (* Retourne en dépilant la valeur de retour et les paramètres [cite: 137] *)
      code_e ^ (return taille_ret taille_params)
  
  | AstPlacement.Empty -> ""

(* analyse_code_bloc : AstPlacement.bloc -> string *)
and analyse_code_bloc (li, taille) =
  let code_instructions = String.concat "" (List.map analyse_code_instruction li) in
  (* On libère les variables locales à la fin du bloc *)
  if taille > 0 then
    code_instructions ^ (pop 0 taille)
  else
    code_instructions

(* analyse_code_fonction : AstPlacement.fonction -> string *)
let analyse_code_fonction (AstPlacement.Fonction (info, _, bloc)) =
  match info_ast_to_info info with
  | InfoFun (nom, _, _) ->
      (label nom) ^ (analyse_code_bloc bloc) ^ (halt) (* halt par sécurité si pas de return *)
  | _ -> failwith "Internal error: Fonction sans InfoFun"

(* analyser : AstPlacement.programme -> string *)
let analyser (AstPlacement.Programme (fonctions, prog)) =
  let entete = getEntete () in
  let code_fonctions = String.concat "" (List.map analyse_code_fonction fonctions) in
  let label_main = label "main" in
  let code_main = analyse_code_bloc prog in
  entete ^ code_fonctions ^ label_main ^ code_main ^ halt