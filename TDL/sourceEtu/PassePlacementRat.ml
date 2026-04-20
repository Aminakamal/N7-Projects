(* Module de la passe de placement mémoire *)
open Tds
open Ast
open Type

type t1 = Ast.AstType.programme
type t2 = Ast.AstPlacement.programme

(* analyse_placement_instruction : AstType.instruction -> int -> string -> (AstPlacement.instruction * int) *)
(* Calcule les adresses des variables et transforme l'instruction *)
(* Retourne l'instruction transformée et la taille occupée par cette instruction (si déclaration) *)
let rec analyse_placement_instruction i depl reg =
  match i with
  | AstType.Declaration (info, e) ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, t, _, _) ->
            let taille = getTaille t in
            (* Mise à jour de l'adresse dans la TDS *)
            modifier_adresse_variable depl reg info;
            (AstPlacement.Declaration (info, e), taille)
        | _ -> failwith "Internal error: Declaration sans InfoVar"
      end
  | AstType.Affectation (info, e) ->
      (AstPlacement.Affectation (info, e), 0)
  | AstType.AffichageInt e ->
      (AstPlacement.AffichageInt e, 0)
  | AstType.AffichageRat e ->
      (AstPlacement.AffichageRat e, 0)
  | AstType.AffichageBool e ->
      (AstPlacement.AffichageBool e, 0)
  | AstType.Conditionnelle (c, t, e) ->
      (* Les blocs internes gèrent leur propre base de déplacement *)
      let nt = analyse_placement_bloc t depl reg in
      let ne = analyse_placement_bloc e depl reg in
      (AstPlacement.Conditionnelle (c, nt, ne), 0)
  | AstType.TantQue (c, b) ->
      let nb = analyse_placement_bloc b depl reg in
      (AstPlacement.TantQue (c, nb), 0)
  | AstType.Retour (e, info) ->
      begin
        match info_ast_to_info info with
        | InfoFun (_, tr, tp) ->
            (* Calcul des tailles nécessaires pour l'instruction RETURN de la TAM *)
            let taille_ret = getTaille tr in
            let taille_params = List.fold_left (fun acc t -> acc + getTaille t) 0 tp in
            (AstPlacement.Retour (e, taille_ret, taille_params), 0)
        | _ -> failwith "Internal error: Retour sans InfoFun"
      end
  | AstType.Empty -> (AstPlacement.Empty, 0)

(* analyse_placement_bloc : AstType.bloc -> int -> string -> (AstPlacement.bloc) *)
(* Retourne le bloc transformé (liste instructions, taille totale du bloc) *)
and analyse_placement_bloc li depl reg =
  let rec aux instructions depl_courant acc_instructions taille_totale =
    match instructions with
    | [] -> (List.rev acc_instructions, taille_totale)
    | i :: rest ->
        let (ni, taille_i) = analyse_placement_instruction i depl_courant reg in
        aux rest (depl_courant + taille_i) (ni :: acc_instructions) (taille_totale + taille_i)
  in
  aux li depl [] 0

(* analyse_placement_fonction : AstType.fonction -> AstPlacement.fonction *)
let analyse_placement_fonction (AstType.Fonction (info, lp, li)) =
  (* Placement des paramètres : déplacements négatifs par rapport à LB *)
  (* On traite la liste inversée pour que le dernier paramètre soit à -1[LB] *)
  let _ = List.fold_left (fun depl infop -> 
    match info_ast_to_info infop with  
    | InfoVar (_, t, _, _) ->
        let taille = getTaille t in
        let nouveau_depl = depl - taille in
        modifier_adresse_variable nouveau_depl "LB" infop;
        nouveau_depl
    | _ -> failwith "Internal error: paramètre sans InfoVar"
  ) 0 (List.rev lp) in 
  
  (* Placement des variables locales : commence à 3[LB] après le chaînage dynamique *)
  let nbloc = analyse_placement_bloc li 3 "LB" in
  
  AstPlacement.Fonction (info, lp, nbloc)

(* analyser : AstType.programme -> AstPlacement.programme *)
let analyser (AstType.Programme (fonctions, prog)) =
  (* 1. Analyser les fonctions *)
  let nf = List.map analyse_placement_fonction fonctions in
  
  (* 2. Analyser le programme principal (registre SB, commence à 0) *)
  let nb = analyse_placement_bloc prog 0 "SB" in
  
  AstPlacement.Programme (nf, nb)