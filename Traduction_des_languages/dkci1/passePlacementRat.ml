(* Module de la passe de placement mémoire *)
open Tds
open Ast
open Type
open Exceptions

type t1 = Ast.AstType.programme
type t2 = Ast.AstPlacement.programme


(* analyse_placement_instruction : AstType.instruction -> int -> string -> (AstPlacement.instruction * int) *)
(* Paramètre i : l'instruction à traiter *)
(* Paramètre depl : déplacement courant dans le bloc *)
(* Paramètre reg : registre de base (SB pour main, LB pour fonctions) *)
(* Renvoie l'instruction avec placement et la taille qu'elle occupe *)
(* Met à jour les adresses des variables déclarées dans la TDS *)
let rec analyse_placement_instruction i depl reg =
  match i with
  | AstType.Declaration (info, e) ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, t, _, _, _) ->
            let taille = getTaille t in
            modifier_adresse_variable depl reg info;
            (AstPlacement.Declaration (info, e), taille)
        | InfoConst (n, _) | InfoFun (n, _, _) ->
            raise (ErreurInterne ("Placement pour déclaration de non-variable: " ^ n))
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("Placement pour enum: " ^ n))
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
            let taille_ret = getTaille tr in
            (* Calculer la taille des paramètres (ref = 1 mot) *)
            let taille_params = List.fold_left (fun acc (t, is_ref) -> 
              acc + (if is_ref then 1 else getTaille t)
            ) 0 tp in
            (AstPlacement.Retour (e, taille_ret, taille_params), 0)
        | InfoVar (n, _, _, _, _) | InfoConst (n, _) ->
            raise (ErreurInterne ("Retour sans InfoFun: " ^ n))
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("Retour associé à enum: " ^ n))
      end

  | AstType.RetourVide info ->
      begin
        match info_ast_to_info info with
        | InfoFun (_, _, tp) ->
            (* Calculer la taille des paramètres *)
            let taille_params = List.fold_left (fun acc (t, is_ref) -> 
              acc + (if is_ref then 1 else getTaille t)
            ) 0 tp in
            (AstPlacement.RetourVide taille_params, 0)
        | InfoVar (n, _, _, _, _) | InfoConst (n, _) ->
            raise (ErreurInterne ("RetourVide sans InfoFun: " ^ n))
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("RetourVide associé à enum: " ^ n))
      end
  
  | AstType.AppelProc (info, le) ->
      (AstPlacement.AppelProc (info, le), 0)
  
  | AstType.Empty -> (AstPlacement.Empty, 0)


(* analyse_placement_bloc : AstType.bloc -> int -> string -> AstPlacement.bloc *)
(* Paramètre li : liste d'instructions du bloc *)
(* Paramètre depl : déplacement initial *)
(* Paramètre reg : registre de base *)
(* Renvoie le bloc avec placement et sa taille totale *)
(* Traite les instructions séquentiellement en mettant à jour le déplacement *)
and analyse_placement_bloc li depl reg =
  let rec aux instructions depl_courant acc_instructions taille_totale =
    match instructions with
    | [] -> ((List.rev acc_instructions, taille_totale) : AstPlacement.bloc)
    | i :: rest ->
        let (ni, taille_i) = analyse_placement_instruction i depl_courant reg in
        aux rest (depl_courant + taille_i) (ni :: acc_instructions) (taille_totale + taille_i)
  in
  aux li depl [] 0


(* analyse_placement_fonction : AstType.fonction -> AstPlacement.fonction *)
(* Paramètre fonction : la fonction à traiter *)
(* Place les paramètres en négatif depuis LB (ordre inverse) *)
(* Place les variables locales en positif à partir de 3[LB] *)
(* Les paramètres ref prennent 1 mot (adresse), les autres prennent leur taille normale *)
let analyse_placement_fonction (AstType.Fonction (info, lp, li)) =
  (* Placement des paramètres : ordre inverse, déplacement négatif depuis 0[LB] *)
  let _ = List.fold_left (fun depl (is_ref, infop) ->
    match info_ast_to_info infop with
    | InfoVar (_, t, _, _, _) ->
        (* Paramètre ref = 1 mot (adresse), sinon taille normale *)
        let taille = if is_ref then 1 else getTaille t in
        let nouveau_depl = depl - taille in
        modifier_adresse_variable nouveau_depl "LB" infop;
        nouveau_depl
    | InfoConst (n, _) | InfoFun (n, _, _) ->
        raise (ErreurInterne ("Placement paramètre non-variable: " ^ n))
    | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
        raise (ErreurInterne ("Placement paramètre enum: " ^ n))
  ) 0 (List.rev lp) in
  
  (* Placement des variables locales : déplacement positif à partir de 3[LB] *)
  let nli = analyse_placement_bloc li 3 "LB" in
  
  AstPlacement.Fonction (info, lp, nli)


(* analyser : AstType.programme -> AstPlacement.programme *)
(* Paramètre programme : le programme à traiter *)
(* Place les variables du programme principal à partir de 0[SB] *)
(* Renvoie le programme avec toutes les adresses calculées *)
let analyser (AstType.Programme (fonctions, prog)) =
  let nf = List.map analyse_placement_fonction fonctions in
  let nb = analyse_placement_bloc prog 0 "SB" in
  AstPlacement.Programme (nf, nb)


(* Tests unitaires de la passe de Placement*)

(* Tests analyse_placement_instruction - déclaration Int *)
let%test_unit "placement_declaration_int" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "", false)) in
  let (_, taille) = analyse_placement_instruction 
    (AstType.Declaration (info_x, AstType.Entier 42)) 
    0 
    "SB" in
  assert (taille = 1);
  match info_ast_to_info info_x with
  | InfoVar (_, _, depl, reg, _) -> 
      assert (depl = 0 && reg = "SB")
  | _ -> failwith "Expected InfoVar"

(* Tests analyse_placement_instruction - déclaration Bool *)
let%test_unit "placement_declaration_bool" =
  let info_b = info_to_info_ast (InfoVar ("b", Bool, 0, "", false)) in
  let (_, taille) = analyse_placement_instruction 
    (AstType.Declaration (info_b, AstType.Booleen true)) 
    3 
    "LB" in
  assert (taille = 1);
  match info_ast_to_info info_b with
  | InfoVar (_, _, depl, reg, _) -> 
      assert (depl = 3 && reg = "LB")
  | _ -> failwith "Expected InfoVar"

(* Tests analyse_placement_instruction - déclaration Rat *)
let%test_unit "placement_declaration_rat" =
  let info_r = info_to_info_ast (InfoVar ("r", Rat, 0, "", false)) in
  let (_, taille) = analyse_placement_instruction 
    (AstType.Declaration (info_r, AstType.Binaire (AstType.Fraction, AstType.Entier 1, AstType.Entier 2))) 
    5 
    "LB" in
  assert (taille = 2);
  match info_ast_to_info info_r with
  | InfoVar (_, _, depl, reg, _) -> 
      assert (depl = 5 && reg = "LB")
  | _ -> failwith "Expected InfoVar"

(* Tests analyse_placement_instruction - déclaration Pointeur *)
let%test_unit "placement_declaration_pointeur" =
  let info_p = info_to_info_ast (InfoVar ("p", Pointeur Int, 0, "", false)) in
  let (_, taille) = analyse_placement_instruction 
    (AstType.Declaration (info_p, AstType.Null)) 
    3 
    "SB" in
  assert (taille = 1);
  match info_ast_to_info info_p with
  | InfoVar (_, _, depl, reg, _) -> 
      assert (depl = 3 && reg = "SB")
  | _ -> failwith "Expected InfoVar"

(* Tests analyse_placement_instruction - affectation ne prend pas de place *)
let%test_unit "placement_affectation_taille_zero" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "SB", false)) in
  let (_, taille) = analyse_placement_instruction 
    (AstType.Affectation (AstTds.Ident info_x, AstType.Entier 5)) 
    0 
    "SB" in
  assert (taille = 0)

(* Tests analyse_placement_instruction - affichage ne prend pas de place *)
let%test_unit "placement_affichage_taille_zero" =
  let (_, taille) = analyse_placement_instruction 
    (AstType.AffichageInt (AstType.Entier 42)) 
    0 
    "SB" in
  assert (taille = 0)

(* Tests analyse_placement_bloc - bloc vide *)
let%test_unit "placement_bloc_vide" =
  let (instructions, taille_totale) = analyse_placement_bloc [] 0 "SB" in
  assert (instructions = []);
  assert (taille_totale = 0)

(* Tests analyse_placement_bloc - une déclaration *)
let%test_unit "placement_bloc_une_declaration" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "", false)) in
  let instructions = [AstType.Declaration (info_x, AstType.Entier 1)] in
  let (_, taille_totale) = analyse_placement_bloc instructions 0 "SB" in
  assert (taille_totale = 1);
  match info_ast_to_info info_x with
  | InfoVar (_, _, depl, _, _) -> assert (depl = 0)
  | _ -> failwith "Expected InfoVar"

(* Tests analyse_placement_bloc - plusieurs déclarations *)
let%test_unit "placement_bloc_plusieurs_declarations" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "", false)) in
  let info_y = info_to_info_ast (InfoVar ("y", Rat, 0, "", false)) in
  let info_z = info_to_info_ast (InfoVar ("z", Bool, 0, "", false)) in
  let instructions = [
    AstType.Declaration (info_x, AstType.Entier 1);
    AstType.Declaration (info_y, AstType.Binaire (AstType.Fraction, AstType.Entier 1, AstType.Entier 2));
    AstType.Declaration (info_z, AstType.Booleen true)
  ] in
  let (_, taille_totale) = analyse_placement_bloc instructions 0 "SB" in
  assert (taille_totale = 4);  (* 1 + 2 + 1 *)
  (* Vérifier les déplacements *)
  match info_ast_to_info info_x with
  | InfoVar (_, _, depl_x, _, _) -> assert (depl_x = 0)
  | _ -> failwith "Expected InfoVar";
  match info_ast_to_info info_y with
  | InfoVar (_, _, depl_y, _, _) -> assert (depl_y = 1)
  | _ -> failwith "Expected InfoVar";
  match info_ast_to_info info_z with
  | InfoVar (_, _, depl_z, _, _) -> assert (depl_z = 3)
  | _ -> failwith "Expected InfoVar"

(* Tests analyse_placement_bloc - avec déplacement initial *)
let%test_unit "placement_bloc_depl_initial" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "", false)) in
  let instructions = [AstType.Declaration (info_x, AstType.Entier 1)] in
  let (_, taille_totale) = analyse_placement_bloc instructions 10 "LB" in
  assert (taille_totale = 1);
  match info_ast_to_info info_x with
  | InfoVar (_, _, depl, reg, _) -> 
      assert (depl = 10 && reg = "LB")
  | _ -> failwith "Expected InfoVar"

(* Tests analyse_placement_fonction - paramètres ordre inverse *)
let%test_unit "placement_fonction_params_ordre_inverse" =
  let info_f = info_to_info_ast (InfoFun ("f", Int, [(Int, false); (Rat, false)])) in
  let info_a = info_to_info_ast (InfoVar ("a", Int, 0, "", false)) in
  let info_b = info_to_info_ast (InfoVar ("b", Rat, 0, "", false)) in
  let fonction = AstType.Fonction (info_f, [(false, info_a); (false, info_b)], []) in
  let _ = analyse_placement_fonction fonction in
  (* Deuxième paramètre b (Rat) doit être à -1[LB] (car traité en dernier) *)
  match info_ast_to_info info_b with
  | InfoVar (_, _, depl_b, reg_b, _) -> 
      assert (depl_b = -2 && reg_b = "LB")
  | _ -> failwith "Expected InfoVar";
  (* Premier paramètre a (Int) doit être à -3[LB] (car b prend 2 mots) *)
  match info_ast_to_info info_a with
  | InfoVar (_, _, depl_a, reg_a, _) -> 
      assert (depl_a = -3 && reg_a = "LB")
  | _ -> failwith "Expected InfoVar"

(* Tests analyse_placement_fonction - variables locales à partir de 3[LB] *)
let%test_unit "placement_fonction_var_locales_3lb" =
  let info_f = info_to_info_ast (InfoFun ("f", Void, [])) in
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "", false)) in
  let fonction = AstType.Fonction (info_f, [], [AstType.Declaration (info_x, AstType.Entier 1)]) in
  let _ = analyse_placement_fonction fonction in
  match info_ast_to_info info_x with
  | InfoVar (_, _, depl, reg, _) -> 
      assert (depl = 3 && reg = "LB")
  | _ -> failwith "Expected InfoVar"


(* Test paramètre ref prend 1 mot *)
let%test_unit "placement_fonction_param_ref_1_mot" =
  let info_f = info_to_info_ast (InfoFun ("f", Void, [(Rat, true)])) in
  let info_a = info_to_info_ast (InfoVar ("a", Rat, 0, "", true)) in
  let fonction = AstType.Fonction (info_f, [(true, info_a)], []) in
  let _ = analyse_placement_fonction fonction in
  (* Paramètre ref Rat : 1 mot au lieu de 2 *)
  match info_ast_to_info info_a with
  | InfoVar (_, _, depl, reg, is_ref) -> 
      assert (depl = -1 && reg = "LB" && is_ref)
  | _ -> failwith "Expected InfoVar"

(* Test mélange paramètres ref et normaux *)
let%test_unit "placement_fonction_params_mixtes" =
  let info_f = info_to_info_ast (InfoFun ("f", Void, [(Int, true); (Rat, false); (Int, false)])) in
  let info_a = info_to_info_ast (InfoVar ("a", Int, 0, "", true)) in
  let info_b = info_to_info_ast (InfoVar ("b", Rat, 0, "", false)) in
  let info_c = info_to_info_ast (InfoVar ("c", Int, 0, "", false)) in
  let fonction = AstType.Fonction (info_f, [(true, info_a); (false, info_b); (false, info_c)], []) in
  let _ = analyse_placement_fonction fonction in
  (* c (Int)     : -1[LB] (1 mot, traité en dernier)
     b (Rat)     : -3[LB] (2 mots)
     a (ref Int) : -4[LB] (1 mot, traité en premier) *)
  match info_ast_to_info info_c with
  | InfoVar (_, _, depl_c, _, _) -> assert (depl_c = -1)
  | _ -> failwith "Expected InfoVar";
  match info_ast_to_info info_b with
  | InfoVar (_, _, depl_b, _, _) -> assert (depl_b = -3)
  | _ -> failwith "Expected InfoVar";
  match info_ast_to_info info_a with
  | InfoVar (_, _, depl_a, _, _) -> assert (depl_a = -4)
  | _ -> failwith "Expected InfoVar"

(* Test Retour avec paramètres ref - calcul taille *)
let%test_unit "placement_retour_params_ref_taille" =
  let info_f = info_to_info_ast (InfoFun ("f", Int, [(Rat, true); (Int, false)])) in
  let info_a = info_to_info_ast (InfoVar ("a", Rat, 0, "", true)) in
  let info_b = info_to_info_ast (InfoVar ("b", Int, 0, "", false)) in
  (* Rat ref = 1 mot, Int normal = 1 mot -> total 2 mots *)
  let inst_retour = AstType.Retour (AstType.Entier 42, info_f) in
  let (AstPlacement.Retour (_, taille_ret, taille_params), _) = 
    analyse_placement_instruction inst_retour 0 "LB" in
  assert (taille_ret = 1);  (* Int *)
  assert (taille_params = 2)  (* 1 (ref Rat) + 1 (Int) *)

(* Test RetourVide avec paramètres ref - calcul taille *)
let%test_unit "placement_retour_vide_params_ref_taille" =
  let info_f = info_to_info_ast (InfoFun ("f", Void, [(Bool, false); (Rat, true); (Int, true)])) in
  (* Bool = 1 mot, Rat ref = 1 mot, Int ref = 1 mot -> total 3 mots *)
  let inst_retour = AstType.RetourVide info_f in
  let (AstPlacement.RetourVide taille_params, _) = 
    analyse_placement_instruction inst_retour 0 "LB" in
  assert (taille_params = 3)  (* 1 + 1 + 1 *)

(* Test déclaration variable enum - taille 1 mot *)
let%test_unit "placement_declaration_enum" =
  let info_c = info_to_info_ast (InfoVar ("c", TypeEnum "Couleur", 0, "", false)) in
  let info_rouge = info_to_info_ast (InfoValeurEnum ("Rouge", "Couleur", 0)) in
  let (_, taille) = analyse_placement_instruction 
    (AstType.Declaration (info_c, AstType.ValeurEnum info_rouge)) 
    0 
    "SB" in
  assert (taille = 1);  (* Enum = 1 mot *)
  match info_ast_to_info info_c with
  | InfoVar (_, TypeEnum "Couleur", depl, reg, _) -> 
      assert (depl = 0 && reg = "SB")
  | _ -> failwith "Expected InfoVar with TypeEnum"

(* Test bloc avec plusieurs variables enum *)
let%test_unit "placement_bloc_plusieurs_enums" =
  let info_c1 = info_to_info_ast (InfoVar ("c1", TypeEnum "Couleur", 0, "", false)) in
  let info_c2 = info_to_info_ast (InfoVar ("c2", TypeEnum "Couleur", 0, "", false)) in
  let info_j = info_to_info_ast (InfoVar ("j", TypeEnum "Jour", 0, "", false)) in
  let info_rouge = info_to_info_ast (InfoValeurEnum ("Rouge", "Couleur", 0)) in
  let info_bleu = info_to_info_ast (InfoValeurEnum ("Bleu", "Couleur", 1)) in
  let info_lundi = info_to_info_ast (InfoValeurEnum ("Lundi", "Jour", 0)) in
  let instructions = [
    AstType.Declaration (info_c1, AstType.ValeurEnum info_rouge);
    AstType.Declaration (info_c2, AstType.ValeurEnum info_bleu);
    AstType.Declaration (info_j, AstType.ValeurEnum info_lundi)
  ] in
  let (_, taille_totale) = analyse_placement_bloc instructions 0 "SB" in
  assert (taille_totale = 3);  (* 3 enums = 3 mots *)
  match info_ast_to_info info_c1 with
  | InfoVar (_, _, depl_c1, _, _) -> assert (depl_c1 = 0)
  | _ -> failwith "Expected InfoVar";
  match info_ast_to_info info_c2 with
  | InfoVar (_, _, depl_c2, _, _) -> assert (depl_c2 = 1)
  | _ -> failwith "Expected InfoVar";
  match info_ast_to_info info_j with
  | InfoVar (_, _, depl_j, _, _) -> assert (depl_j = 2)
  | _ -> failwith "Expected InfoVar"

(* Test fonction avec paramètre enum *)
let%test_unit "placement_fonction_param_enum" =
  let info_f = info_to_info_ast (InfoFun ("f", Bool, [(TypeEnum "Jour", false)])) in
  let info_j = info_to_info_ast (InfoVar ("j", TypeEnum "Jour", 0, "", false)) in
  let fonction = AstType.Fonction (info_f, [(false, info_j)], []) in
  let _ = analyse_placement_fonction fonction in
  (* Paramètre enum : 1 mot à -1[LB] *)
  match info_ast_to_info info_j with
  | InfoVar (_, TypeEnum "Jour", depl, reg, _) -> 
      assert (depl = -1 && reg = "LB")
  | _ -> failwith "Expected InfoVar"

(* Test fonction avec paramètre ref enum *)
let%test_unit "placement_fonction_param_ref_enum" =
  let info_f = info_to_info_ast (InfoFun ("f", Void, [(TypeEnum "Couleur", true)])) in
  let info_c = info_to_info_ast (InfoVar ("c", TypeEnum "Couleur", 0, "", true)) in
  let fonction = AstType.Fonction (info_f, [(true, info_c)], []) in
  let _ = analyse_placement_fonction fonction in
  (* Paramètre ref enum : 1 mot (adresse) à -1[LB] *)
  match info_ast_to_info info_c with
  | InfoVar (_, TypeEnum "Couleur", depl, reg, is_ref) -> 
      assert (depl = -1 && reg = "LB" && is_ref)
  | _ -> failwith "Expected InfoVar"

(* Test bloc mixte : enum, int, rat *)
let%test_unit "placement_bloc_mixte_enum_int_rat" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "", false)) in
  let info_c = info_to_info_ast (InfoVar ("c", TypeEnum "Couleur", 0, "", false)) in
  let info_r = info_to_info_ast (InfoVar ("r", Rat, 0, "", false)) in
  let info_rouge = info_to_info_ast (InfoValeurEnum ("Rouge", "Couleur", 0)) in
  let instructions = [
    AstType.Declaration (info_x, AstType.Entier 5);
    AstType.Declaration (info_c, AstType.ValeurEnum info_rouge);
    AstType.Declaration (info_r, AstType.Binaire (AstType.Fraction, AstType.Entier 1, AstType.Entier 2))
  ] in
  let (_, taille_totale) = analyse_placement_bloc instructions 0 "SB" in
  assert (taille_totale = 4);  (* 1 + 1 + 2 *)
  match info_ast_to_info info_x with
  | InfoVar (_, _, depl_x, _, _) -> assert (depl_x = 0)
  | _ -> failwith "Expected InfoVar";
  match info_ast_to_info info_c with
  | InfoVar (_, _, depl_c, _, _) -> assert (depl_c = 1)
  | _ -> failwith "Expected InfoVar";
  match info_ast_to_info info_r with
  | InfoVar (_, _, depl_r, _, _) -> assert (depl_r = 2)
  | _ -> failwith "Expected InfoVar"

(* Test retour fonction avec paramètre enum *)
let%test_unit "placement_retour_fonction_enum" =
  let info_f = info_to_info_ast (InfoFun ("f", Bool, [(TypeEnum "Jour", false); (Int, false)])) in
  let inst_retour = AstType.Retour (AstType.Booleen true, info_f) in
  let (AstPlacement.Retour (_, taille_ret, taille_params), _) = 
    analyse_placement_instruction inst_retour 0 "LB" in
  assert (taille_ret = 1);  (* Bool *)
  assert (taille_params = 2)  (* 1 (enum) + 1 (int) *)
