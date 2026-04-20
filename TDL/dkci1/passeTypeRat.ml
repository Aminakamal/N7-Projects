(* Module de la passe de typage *)
open Tds
open Exceptions
open Ast
open Type

type t1 = Ast.AstTds.programme
type t2 = Ast.AstType.programme


(* analyse_type_affectable : AstTds.affectable -> typ *)
(* Paramètre a : l'affectable à analyser *)
(* Renvoie le type de l'affectable *)
(* Erreur si déréférencement d'un non-pointeur *)
let rec analyse_type_affectable a =
  match a with
  | AstTds.Ident info ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, t, _, _, _) -> t
        | InfoConst (_, _) -> Int
        | InfoFun (nom, _, _) -> raise (AffectableInvalide nom)
        | InfoTypeEnum _ | InfoValeurEnum _ -> 
            raise (ErreurInterne "Type/Valeur enum comme affectable")
      end
  | AstTds.Deref a ->
      let ta = analyse_type_affectable a in
      begin
        match ta with
        | Pointeur t -> t
        | autre_type -> raise (DerefNonPointeur autre_type)
      end


(* analyse_type_expression : AstTds.expression -> (AstType.expression * typ) *)
(* Paramètre e : l'expression à analyser *)
(* Renvoie l'expression typée et son type *)
(* Erreur si incompatibilité de types *)
let rec analyse_type_expression e =
  match e with
  | AstTds.AppelFonction (info, le) ->
      begin
        match info_ast_to_info info with
        | InfoFun (nom, tr, tp) ->
            let nle_types = List.map analyse_type_expression le in
            let nle, types_reels = List.split nle_types in
            
            (* Vérifier le nombre de paramètres *)
            let nb_params_ok = List.length tp = List.length nle in
            if not nb_params_ok then
              raise (TypesParametresInattendus (types_reels, List.map fst tp));
            
            (* Vérifier correspondance des ref *)
            let refs_ok = 
              try 
                List.for_all2 (fun (_, is_ref_attendu) expr_param ->
                  match expr_param with
                  | AstType.Ref _ -> is_ref_attendu
                  | _ -> not is_ref_attendu
                ) tp nle
              with Invalid_argument _ -> false
            in
            
            if not refs_ok then
              raise (ParametreRefIncorrect nom);
            
            (* Vérifier compatibilité des types *)
            let types_ok = 
              try
                List.for_all2 (fun (t_attendu, is_ref_attendu) (_, t_reel) ->
                  if is_ref_attendu then
                    (* Pour ref : comparer le type contenu dans le pointeur *)
                    match t_reel with
                    | Pointeur t_contenu -> est_compatible t_attendu t_contenu
                    | _ -> false
                  else
                    est_compatible t_attendu t_reel
                ) tp (List.combine nle types_reels)
              with Invalid_argument _ -> false
            in
            
            if not types_ok then
              raise (TypesParametresInattendus (types_reels, List.map fst tp));
            
            (AstType.AppelFonction (info, nle), tr)
        
        | InfoVar (n, _, _, _, _) | InfoConst (n, _) ->
            raise (ErreurInterne ("AppelFonction sur non-fonction: " ^ n))
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("AppelFonction sur enum: " ^ n))
      end
    
  | AstTds.Affectable a ->
      let t = analyse_type_affectable a in
      (AstType.Affectable a, t)
  
  | AstTds.Booleen b -> (AstType.Booleen b, Bool)
  | AstTds.Entier i -> (AstType.Entier i, Int)
  | AstTds.Null -> (AstType.Null, Pointeur Undefined)
  | AstTds.New t -> (AstType.New t, Pointeur t)
  
  | AstTds.Adresse info ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, t, _, _, _) ->
            (AstType.Adresse info, Pointeur t)
        | InfoConst (n, _) | InfoFun (n, _, _) ->
            raise (ErreurInterne ("Adresse sur non-variable: " ^ n))
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("Adresse sur enum: " ^ n))
      end
  
  | AstTds.Ref info ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, t, _, _, _) ->
            (AstType.Ref info, Pointeur t)
        | InfoConst (n, _) | InfoFun (n, _, _) ->
            raise (ErreurInterne ("Ref sur non-variable: " ^ n))
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("Ref sur enum: " ^ n))
      end
  
  | AstTds.ValeurEnum info ->
      begin
        match info_ast_to_info info with
        | InfoValeurEnum (_, nom_type, _) ->
            (AstType.ValeurEnum info, TypeEnum nom_type)
        | _ ->
            raise (ErreurInterne "ValeurEnum sans InfoValeurEnum")
      end
  
  | AstTds.Unaire (op, e1) ->
      let (ne1, t1) = analyse_type_expression e1 in
      begin
        match op with
        | AstSyntax.Numerateur ->
            if est_compatible Rat t1 then
              (AstType.Unaire (AstType.Numerateur, ne1), Int)
            else
              raise (TypeInattendu (t1, Rat))
        | AstSyntax.Denominateur ->
            if est_compatible Rat t1 then
              (AstType.Unaire (AstType.Denominateur, ne1), Int)
            else
              raise (TypeInattendu (t1, Rat))
      end
  
  | AstTds.Binaire (b, e1, e2) ->
      let (ne1, t1) = analyse_type_expression e1 in
      let (ne2, t2) = analyse_type_expression e2 in
      begin
        match b with
        | AstSyntax.Fraction ->
            if est_compatible Int t1 && est_compatible Int t2 then
              (AstType.Binaire (AstType.Fraction, ne1, ne2), Rat)
            else
              raise (TypeBinaireInattendu (b, t1, t2))
        | AstSyntax.Plus ->
            if est_compatible Int t1 && est_compatible Int t2 then
              (AstType.Binaire (AstType.PlusInt, ne1, ne2), Int)
            else if est_compatible Rat t1 && est_compatible Rat t2 then
              (AstType.Binaire (AstType.PlusRat, ne1, ne2), Rat)
            else
              raise (TypeBinaireInattendu (b, t1, t2))
        | AstSyntax.Mult ->
            if est_compatible Int t1 && est_compatible Int t2 then
              (AstType.Binaire (AstType.MultInt, ne1, ne2), Int)
            else if est_compatible Rat t1 && est_compatible Rat t2 then
              (AstType.Binaire (AstType.MultRat, ne1, ne2), Rat)
            else
              raise (TypeBinaireInattendu (b, t1, t2))
        | AstSyntax.Equ ->
            if est_compatible Int t1 && est_compatible Int t2 then
              (AstType.Binaire (AstType.EquInt, ne1, ne2), Bool)
            else if est_compatible Bool t1 && est_compatible Bool t2 then
              (AstType.Binaire (AstType.EquBool, ne1, ne2), Bool)
            else if est_compatible t1 t2 then
              (* Deux valeurs du même type enum *)
              begin
                match t1, t2 with
                | TypeEnum _, TypeEnum _ ->
                    (AstType.Binaire (AstType.EquEnum, ne1, ne2), Bool)
                | _ ->
                    raise (TypeBinaireInattendu (b, t1, t2))
              end
            else
              raise (TypeBinaireInattendu (b, t1, t2))
        | AstSyntax.Inf ->
            if est_compatible Int t1 && est_compatible Int t2 then
              (AstType.Binaire (AstType.Inf, ne1, ne2), Bool)
            else
              raise (TypeBinaireInattendu (b, t1, t2))
      end


(* analyse_type_instruction : AstTds.instruction -> AstType.instruction *)
(* Paramètre i : l'instruction à analyser *)
(* Renvoie l'instruction typée *)
(* Erreur si incompatibilité de types *)
let rec analyse_type_instruction i =
  match i with
  | AstTds.Declaration (t, info, e) ->
      let (ne, te) = analyse_type_expression e in
      if est_compatible t te then
        begin
          modifier_type_variable t info;
          AstType.Declaration (info, ne)
        end
      else
        raise (TypeInattendu (te, t))
  
  | AstTds.Affectation (a, e) ->
      let ta = analyse_type_affectable a in
      let (ne, te) = analyse_type_expression e in
      if est_compatible ta te then
        AstType.Affectation (a, ne)
      else
        raise (TypeInattendu (te, ta))
  
  | AstTds.Affichage e ->
      let (ne, te) = analyse_type_expression e in
      begin
        match te with
        | Int -> AstType.AffichageInt ne
        | Rat -> AstType.AffichageRat ne
        | Bool -> AstType.AffichageBool ne
        | TypeEnum _ -> raise (AffichageTypeInvalide te)
        | Void -> raise (AffichageTypeInvalide Void)
        | Pointeur t -> raise (AffichageTypeInvalide (Pointeur t))
        | Undefined -> raise (ErreurInterne "Type Undefined lors de l'affichage")
      end
  
  | AstTds.Conditionnelle (c, t, e) ->
      let (nc, tc) = analyse_type_expression c in
      if est_compatible Bool tc then
        let nt = analyse_type_bloc t in
        let ne = analyse_type_bloc e in
        AstType.Conditionnelle (nc, nt, ne)
      else
        raise (TypeInattendu (tc, Bool))
  
  | AstTds.TantQue (c, b) ->
      let (nc, tc) = analyse_type_expression c in
      if est_compatible Bool tc then
        let nb = analyse_type_bloc b in
        AstType.TantQue (nc, nb)
      else
        raise (TypeInattendu (tc, Bool))
  
  | AstTds.Retour (e, info) ->
      begin
        match info_ast_to_info info with
        | InfoFun (_, tr, _) ->
            let (ne, te) = analyse_type_expression e in
            if est_compatible Void tr then
              raise RetourAvecValeurDansVoid
            else if est_compatible tr te then
              AstType.Retour (ne, info)
            else
              raise (TypeInattendu (te, tr))
        | InfoVar (n, _, _, _, _) | InfoConst (n, _) ->
            raise (ErreurInterne ("Retour associé à non-fonction: " ^ n))
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("Retour associé à enum: " ^ n))
      end
  
  | AstTds.RetourVide info ->
      begin
        match info_ast_to_info info with
        | InfoFun (_, tr, _) ->
            if est_compatible Void tr then
              AstType.RetourVide info
            else
              raise (RetourVideDansNonVoid tr)
        | InfoVar (n, _, _, _, _) | InfoConst (n, _) ->
            raise (ErreurInterne ("RetourVide associé à non-fonction: " ^ n))
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("RetourVide associé à enum: " ^ n))
      end
  
  | AstTds.AppelProc (info, le) ->
      begin
        match info_ast_to_info info with
        | InfoFun (nom, tr, tp) ->
            let nle_types = List.map analyse_type_expression le in
            let nle, types_reels = List.split nle_types in
            
            (* Vérifier le nombre de paramètres *)
            let nb_params_ok = List.length tp = List.length nle in
            if not nb_params_ok then
              raise (TypesParametresInattendus (types_reels, List.map fst tp));
            
            (* Vérifier correspondance des ref *)
            let refs_ok = 
              try 
                List.for_all2 (fun (_, is_ref_attendu) expr_param ->
                  match expr_param with
                  | AstType.Ref _ -> is_ref_attendu
                  | _ -> not is_ref_attendu
                ) tp nle
              with Invalid_argument _ -> false
            in
            
            if not refs_ok then
              raise (ParametreRefIncorrect nom);
              
            (* Vérifier compatibilité des types *)
            let types_ok = 
              try
                List.for_all2 (fun (t_attendu, is_ref_attendu) (_, t_reel) ->
                  if is_ref_attendu then
                    match t_reel with
                    | Pointeur t_contenu -> est_compatible t_attendu t_contenu
                    | _ -> false
                  else
                    est_compatible t_attendu t_reel
                ) tp (List.combine nle types_reels)
              with Invalid_argument _ -> false
            in
            
            if not types_ok then
              raise (TypesParametresInattendus (types_reels, List.map fst tp));
            
            if est_compatible Void tr then
              AstType.AppelProc (info, nle)
            else
              raise (AppelFonctionCommeProc (nom, tr))
        
        | InfoVar (n, _, _, _, _) | InfoConst (n, _) ->
            raise (MauvaiseUtilisationIdentifiant n)
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("AppelProc sur enum: " ^ n))
      end
  
  | AstTds.Empty -> AstType.Empty


(* analyse_type_bloc : AstTds.bloc -> AstType.bloc *)
(* Paramètre li : liste d'instructions à typer *)
(* Renvoie la liste d'instructions typées *)
and analyse_type_bloc li =
  List.map analyse_type_instruction li


(* analyse_type_fonction : AstTds.fonction -> AstType.fonction *)
(* Paramètre fonction : la fonction à typer *)
(* Met à jour les types des paramètres et de la fonction *)
(* Renvoie la fonction typée *)
let analyse_type_fonction (AstTds.Fonction (t, info, lp, li)) =
  (* Mettre à jour les types des paramètres *)
  let nlp =
    List.map
      (fun (tp, is_ref, infop) ->
        modifier_type_variable tp infop;
        (is_ref, infop)
      )
      lp
  in
  
  (* Construire la liste (typ * bool) pour InfoFun *)
  let types_params = List.map (fun (tp, is_ref, _) -> (tp, is_ref)) lp in
  modifier_type_fonction t types_params info;
  
  let nli = analyse_type_bloc li in
  AstType.Fonction (info, nlp, nli)


(* analyser : AstTds.programme -> AstType.programme *)
(* Paramètre programme : le programme à typer *)
(* Renvoie le programme typé *)
let analyser (AstTds.Programme (fonctions, prog)) =
  let nf = List.map analyse_type_fonction fonctions in
  let nb = analyse_type_bloc prog in
  AstType.Programme (nf, nb)


(* TESTS unitaires de la passe Typage *)

(* Tests analyse_type_affectable - variable *)
let%test_unit "type_affectable_var_int" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "SB", false)) in
  let resultat = analyse_type_affectable (AstTds.Ident info_x) in
  assert (resultat = Int)

let%test_unit "type_affectable_var_rat" =
  let info_r = info_to_info_ast (InfoVar ("r", Rat, 0, "SB", false)) in
  let resultat = analyse_type_affectable (AstTds.Ident info_r) in
  assert (resultat = Rat)

let%test_unit "type_affectable_var_bool" =
  let info_b = info_to_info_ast (InfoVar ("b", Bool, 0, "SB", false)) in
  let resultat = analyse_type_affectable (AstTds.Ident info_b) in
  assert (resultat = Bool)

(* Tests analyse_type_affectable - constante *)
let%test_unit "type_affectable_const" =
  let info_c = info_to_info_ast (InfoConst ("c", 42)) in
  let resultat = analyse_type_affectable (AstTds.Ident info_c) in
  assert (resultat = Int)

(* Tests analyse_type_affectable - déréférencement *)
let%test_unit "type_affectable_deref_int" =
  let info_p = info_to_info_ast (InfoVar ("p", Pointeur Int, 0, "SB", false)) in
  let resultat = analyse_type_affectable (AstTds.Deref (AstTds.Ident info_p)) in
  assert (resultat = Int)

let%test_unit "type_affectable_deref_rat" =
  let info_p = info_to_info_ast (InfoVar ("p", Pointeur Rat, 0, "SB", false)) in
  let resultat = analyse_type_affectable (AstTds.Deref (AstTds.Ident info_p)) in
  assert (resultat = Rat)

let%test_unit "type_affectable_deref_pointeur" =
  let info_pp = info_to_info_ast (InfoVar ("pp", Pointeur (Pointeur Int), 0, "SB", false)) in
  let resultat = analyse_type_affectable (AstTds.Deref (AstTds.Ident info_pp)) in
  assert (resultat = Pointeur Int)

(* Tests analyse_type_affectable - déréférencement non-pointeur *)
let%test_unit "type_affectable_deref_non_pointeur" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "SB", false)) in
  try
    let _ = analyse_type_affectable (AstTds.Deref (AstTds.Ident info_x)) in
    assert false
  with
  | DerefNonPointeur Int -> ()
  | _ -> assert false

(* Tests analyse_type_affectable - fonction interdite *)
let%test_unit "type_affectable_fonction_erreur" =
  let info_f = info_to_info_ast (InfoFun ("f", Int, [])) in
  try
    let _ = analyse_type_affectable (AstTds.Ident info_f) in
    assert false
  with
  | AffectableInvalide "f" -> ()
  | _ -> assert false

(* Tests analyse_type_expression - types simples *)
let%test_unit "type_expression_entier" =
  let (_, t) = analyse_type_expression (AstTds.Entier 42) in
  assert (t = Int)

let%test_unit "type_expression_booleen_true" =
  let (_, t) = analyse_type_expression (AstTds.Booleen true) in
  assert (t = Bool)

let%test_unit "type_expression_booleen_false" =
  let (_, t) = analyse_type_expression (AstTds.Booleen false) in
  assert (t = Bool)

(* Tests analyse_type_expression - pointeurs *)
let%test_unit "type_expression_null" =
  let (_, t) = analyse_type_expression AstTds.Null in
  assert (t = Pointeur Undefined)

let%test_unit "type_expression_new_int" =
  let (_, t) = analyse_type_expression (AstTds.New Int) in
  assert (t = Pointeur Int)

let%test_unit "type_expression_new_rat" =
  let (_, t) = analyse_type_expression (AstTds.New Rat) in
  assert (t = Pointeur Rat)

let%test_unit "type_expression_adresse" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "SB", false)) in
  let (_, t) = analyse_type_expression (AstTds.Adresse info_x) in
  assert (t = Pointeur Int)

(* Tests analyse_type_expression - unaires *)
let%test_unit "type_expression_numerateur" =
  let info_r = info_to_info_ast (InfoVar ("r", Rat, 0, "SB", false)) in
  let (_, t) = analyse_type_expression 
    (AstTds.Unaire (AstSyntax.Numerateur, AstTds.Affectable (AstTds.Ident info_r))) in
  assert (t = Int)

let%test_unit "type_expression_denominateur" =
  let info_r = info_to_info_ast (InfoVar ("r", Rat, 0, "SB", false)) in
  let (_, t) = analyse_type_expression 
    (AstTds.Unaire (AstSyntax.Denominateur, AstTds.Affectable (AstTds.Ident info_r))) in
  assert (t = Int)

(* Tests analyse_type_expression - binaires *)
let%test_unit "type_expression_fraction" =
  let (_, t) = analyse_type_expression 
    (AstTds.Binaire (AstSyntax.Fraction, AstTds.Entier 1, AstTds.Entier 2)) in
  assert (t = Rat)

let%test_unit "type_expression_plus_int" =
  let (_, t) = analyse_type_expression 
    (AstTds.Binaire (AstSyntax.Plus, AstTds.Entier 1, AstTds.Entier 2)) in
  assert (t = Int)

let%test_unit "type_expression_plus_rat" =
  let e_rat1 = AstTds.Binaire (AstSyntax.Fraction, AstTds.Entier 1, AstTds.Entier 2) in
  let e_rat2 = AstTds.Binaire (AstSyntax.Fraction, AstTds.Entier 3, AstTds.Entier 4) in
  let (_, t) = analyse_type_expression 
    (AstTds.Binaire (AstSyntax.Plus, e_rat1, e_rat2)) in
  assert (t = Rat)

let%test_unit "type_expression_mult_int" =
  let (_, t) = analyse_type_expression 
    (AstTds.Binaire (AstSyntax.Mult, AstTds.Entier 2, AstTds.Entier 3)) in
  assert (t = Int)

let%test_unit "type_expression_equ_int" =
  let (_, t) = analyse_type_expression 
    (AstTds.Binaire (AstSyntax.Equ, AstTds.Entier 1, AstTds.Entier 2)) in
  assert (t = Bool)

let%test_unit "type_expression_equ_bool" =
  let (_, t) = analyse_type_expression 
    (AstTds.Binaire (AstSyntax.Equ, AstTds.Booleen true, AstTds.Booleen false)) in
  assert (t = Bool)

let%test_unit "type_expression_inf" =
  let (_, t) = analyse_type_expression 
    (AstTds.Binaire (AstSyntax.Inf, AstTds.Entier 1, AstTds.Entier 2)) in
  assert (t = Bool)

(* Tests ref *)
let%test_unit "type_expression_ref" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "SB", false)) in
  let (_, t) = analyse_type_expression (AstTds.Ref info_x) in
  assert (t = Pointeur Int)

let%test_unit "type_expression_ref_rat" =
  let info_r = info_to_info_ast (InfoVar ("r", Rat, 0, "SB", false)) in
  let (_, t) = analyse_type_expression (AstTds.Ref info_r) in
  assert (t = Pointeur Rat)
  
(* Tests Enum *)
let%test_unit "type_expression_valeur_enum" =
  let info_rouge = info_to_info_ast (InfoValeurEnum ("Rouge", "Couleur", 0)) in
  let (_, t) = analyse_type_expression (AstTds.ValeurEnum info_rouge) in
  assert (t = TypeEnum "Couleur")

let%test_unit "type_equ_enum_meme_type" =
  let info_rouge = info_to_info_ast (InfoValeurEnum ("Rouge", "Couleur", 0)) in
  let info_bleu = info_to_info_ast (InfoValeurEnum ("Bleu", "Couleur", 1)) in
  let e1 = AstTds.ValeurEnum info_rouge in
  let e2 = AstTds.ValeurEnum info_bleu in
  let (_, t) = analyse_type_expression (AstTds.Binaire (AstSyntax.Equ, e1, e2)) in
  assert (t = Bool)

let%test_unit "type_equ_enum_types_differents" =
  let info_rouge = info_to_info_ast (InfoValeurEnum ("Rouge", "Couleur", 0)) in
  let info_lundi = info_to_info_ast (InfoValeurEnum ("Lundi", "Jour", 0)) in
  let e1 = AstTds.ValeurEnum info_rouge in
  let e2 = AstTds.ValeurEnum info_lundi in
  try
    let _ = analyse_type_expression (AstTds.Binaire (AstSyntax.Equ, e1, e2)) in
    assert false
  with
  | TypeBinaireInattendu _ -> ()
  | _ -> assert false

let%test_unit "type_declaration_var_enum" =
  let info_couleur = info_to_info_ast (InfoVar ("c", Undefined, 0, "SB", false)) in
  let info_rouge = info_to_info_ast (InfoValeurEnum ("Rouge", "Couleur", 0)) in
  let expr = AstTds.ValeurEnum info_rouge in
  let instr = AstTds.Declaration (TypeEnum "Couleur", info_couleur, expr) in
  let _ = analyse_type_instruction instr in
  match info_ast_to_info info_couleur with
  | InfoVar (_, TypeEnum "Couleur", _, _, _) -> ()
  | _ -> assert false

let%test_unit "type_affichage_enum_interdit" =
  let info_rouge = info_to_info_ast (InfoValeurEnum ("Rouge", "Couleur", 0)) in
  let expr = AstTds.ValeurEnum info_rouge in
  let instr = AstTds.Affichage expr in
  try
    let _ = analyse_type_instruction instr in
    assert false
  with
  | AffichageTypeInvalide (TypeEnum "Couleur") -> ()
  | _ -> assert false
