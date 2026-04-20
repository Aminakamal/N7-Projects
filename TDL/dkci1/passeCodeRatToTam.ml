(* Module de la passe de génération de code TAM *)
open Tds
open Ast
open Code
open Tam
open Type
open Exceptions

type t1 = Ast.AstPlacement.programme
type t2 = string


(* analyse_type_affectable : AstTds.affectable -> typ *)
(* Fonction auxiliaire pour récupérer le type d'un affectable *)
(* Nécessaire pour connaître la taille lors de STOREI *)
let rec analyse_type_affectable a =
  match a with
  | AstTds.Ident info ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, t, _, _, _) -> t
        | InfoConst (_, _) -> Int
        | InfoFun (n, _, _) ->
            raise (ErreurInterne ("Type d'affectable sur fonction: " ^ n))
        | InfoTypeEnum _ | InfoValeurEnum _ ->
            raise (ErreurInterne "Type d'affectable sur enum")
      end
  | AstTds.Deref a ->
      let ta = analyse_type_affectable a in
      begin
        match ta with
        | Pointeur t -> t
        | autre_type -> raise (DerefNonPointeur autre_type)
      end


(* analyse_code_affectable : AstPlacement.affectable -> bool -> string *)
(* Paramètre a : l'affectable à traiter *)
(* Paramètre is_left : true si partie gauche (écriture), false si lecture *)
(* Génère le code pour accéder à un affectable *)
(* Pour lecture : empile la valeur *)
(* Pour écriture : empile l'adresse *)
let rec analyse_code_affectable a is_left =
  match a with
  | AstTds.Ident info ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, t, depl, reg, is_ref) ->
            if is_ref then
              (* Paramètre ref : l'adresse est stockée à depl[reg] *)
              if is_left then
                (* Écriture : charger l'adresse stockée *)
                load 1 depl reg
              else
                (* Lecture : charger l'adresse puis la valeur *)
                (load 1 depl reg) ^ (loadi (getTaille t))
            else
              (* Variable normale *)
              if is_left then
                loada depl reg
              else
                load (getTaille t) depl reg
        
        | InfoConst (_, v) ->
            if is_left then
              raise (ErreurInterne "Tentative d'affectation à une constante")
            else
              loadl_int v
        
        | InfoFun (n, _, _) ->
            raise (ErreurInterne ("Génération code pour fonction comme affectable: " ^ n))
        
        | InfoTypeEnum _ | InfoValeurEnum _ ->
            raise (ErreurInterne "Affectable sur enum")
      end
  
  | AstTds.Deref a ->
      let code_adr = analyse_code_affectable a false in
      let ta = analyse_type_affectable a in
      begin
        match ta with
        | Pointeur t ->
            let taille = getTaille t in
            if is_left then
              code_adr
            else
              code_adr ^ (loadi taille)
        | autre_type -> raise (DerefNonPointeur autre_type)
      end


(* analyse_code_expression : AstPlacement.expression -> string *)
(* Paramètre e : l'expression à compiler *)
(* Génère le code TAM qui empile la valeur de l'expression *)
let rec analyse_code_expression e =
  match e with
  | AstType.AppelFonction (info, le) ->
      begin
        match info_ast_to_info info with
        | InfoFun (nom, _, tp) ->
            (* Empiler les paramètres avec gestion ref *)
            let code_params = List.fold_left2 (fun acc (_, is_ref) e_param ->
              let code_param = 
                if is_ref then
                  (* Paramètre ref : doit être (Ref info) *)
                  match e_param with
                  | AstType.Ref info_var ->
                      begin
                        match info_ast_to_info info_var with
                        | InfoVar (_, _, depl, reg, is_ref_inner) ->
                            if is_ref_inner then
                              (* Chaînage de ref : charger l'adresse contenue *)
                              load 1 depl reg
                            else
                              (* Variable normale : empiler son adresse *)
                              loada depl reg
                        | _ -> raise (ErreurInterne "Ref sur non-variable")
                      end
                  | _ -> raise (ErreurInterne "Paramètre ref attendu mais pas fourni")
                else
                  (* Paramètre normal : évaluer l'expression *)
                  analyse_code_expression e_param
              in
              acc ^ code_param
            ) "" tp le in
            code_params ^ (call "ST" nom)
        
        | InfoVar (n, _, _, _, _) | InfoConst (n, _) ->
            raise (ErreurInterne ("AppelFonction sur non-fonction: " ^ n))
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("AppelFonction sur enum: " ^ n))
      end
  
  | AstType.Affectable a ->
      analyse_code_affectable a false
  
  | AstType.Booleen b ->
      if b then loadl_int 1 else loadl_int 0
  
  | AstType.Entier i ->
      loadl_int i
  
  | AstType.Null ->
      loadl_int 0
  
  | AstType.New t ->
      let taille = getTaille t in
      (loadl_int taille) ^ (subr "MAlloc")
  
  | AstType.Adresse info ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, _, depl, reg, _) ->
            loada depl reg
        | InfoConst (n, _) | InfoFun (n, _, _) ->
            raise (ErreurInterne ("Adresse sur non-variable: " ^ n))
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("Adresse sur enum: " ^ n))
      end
  
  | AstType.Ref info ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, _, depl, reg, is_ref) ->
            if is_ref then
              (* Chaînage : charger l'adresse contenue *)
              load 1 depl reg
            else
              (* Variable normale : empiler son adresse *)
              loada depl reg
        | InfoConst (n, _) | InfoFun (n, _, _) ->
            raise (ErreurInterne ("Ref sur non-variable: " ^ n))
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("Ref sur enum: " ^ n))
      end
  
  | AstType.ValeurEnum info ->
      begin
        match info_ast_to_info info with
        | InfoValeurEnum (_, _, index) ->
            (* Une valeur enum est représentée par son index (0, 1, 2...) *)
            loadl_int index
        | _ ->
            raise (ErreurInterne "ValeurEnum sans InfoValeurEnum")
      end
  
  | AstType.Unaire (op, e1) ->
      let code_e1 = analyse_code_expression e1 in
      begin
        match op with
        | AstType.Numerateur ->
            code_e1 ^ (pop 0 1)
        | AstType.Denominateur ->
            code_e1 ^ (pop 1 1)
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
        | AstType.EquEnum ->
            (* Comparaison d'enums : ce sont des entiers *)
            code_e1 ^ code_e2 ^ (subr "IEq")
        | AstType.Inf ->
            code_e1 ^ code_e2 ^ (subr "ILss")
      end


(* analyse_code_instruction : AstPlacement.instruction -> string *)
(* Paramètre i : l'instruction à compiler *)
(* Génère le code TAM correspondant *)
let rec analyse_code_instruction i =
  match i with
  | AstPlacement.Declaration (info, e) ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, t, depl, reg, _) ->
            let taille = getTaille t in
            let code_e = analyse_code_expression e in
            (push taille) ^ code_e ^ (store taille depl reg)
        | InfoConst (n, _) | InfoFun (n, _, _) ->
            raise (ErreurInterne ("Declaration de non-variable: " ^ n))
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("Declaration de enum: " ^ n))
      end
  
  | AstPlacement.Affectation (a, e) ->
      let code_e = analyse_code_expression e in
      let ta = analyse_type_affectable a in
      let taille = getTaille ta in
      let code_adr = analyse_code_affectable a true in
      code_e ^ code_adr ^ (storei taille)
  
  | AstPlacement.AffichageInt e ->
      let code_e = analyse_code_expression e in
      code_e ^ (subr "IOut")
  
  | AstPlacement.AffichageRat e ->
      let code_e = analyse_code_expression e in
      code_e ^ (call "ST" "ROut")
  
  | AstPlacement.AffichageBool e ->
      let code_e = analyse_code_expression e in
      code_e ^ (subr "BOut")
  
  | AstPlacement.Conditionnelle (c, (bt, tt), (be, te)) ->
      let label_else = getEtiquette () in
      let label_fin = getEtiquette () in
      let code_c = analyse_code_expression c in
      let code_then = analyse_code_bloc (bt, tt) in
      let code_else = analyse_code_bloc (be, te) in
      code_c ^
      (jumpif 0 label_else) ^
      code_then ^
      (jump label_fin) ^
      (label label_else) ^
      code_else ^
      (label label_fin)
  
  | AstPlacement.TantQue (c, (b, tb)) ->
      let label_debut = getEtiquette () in
      let label_fin = getEtiquette () in
      let code_c = analyse_code_expression c in
      let code_bloc = analyse_code_bloc (b, tb) in
      (label label_debut) ^
      code_c ^
      (jumpif 0 label_fin) ^
      code_bloc ^
      (jump label_debut) ^
      (label label_fin)
  
  | AstPlacement.Retour (e, taille_ret, taille_params) ->
      let code_e = analyse_code_expression e in
      code_e ^ (return taille_ret taille_params)
  
  | AstPlacement.RetourVide taille_params ->
      return 0 taille_params
  
  | AstPlacement.AppelProc (info, le) ->
      begin
        match info_ast_to_info info with
        | InfoFun (nom, _, tp) ->
            (* Même logique que AppelFonction *)
            let code_params = List.fold_left2 (fun acc (_, is_ref) e_param ->
              let code_param = 
                if is_ref then
                  match e_param with
                  | AstType.Ref info_var ->
                      begin
                        match info_ast_to_info info_var with
                        | InfoVar (_, _, depl, reg, is_ref_inner) ->
                            if is_ref_inner then
                              load 1 depl reg
                            else
                              loada depl reg
                        | _ -> raise (ErreurInterne "Ref sur non-variable")
                      end
                  | _ -> raise (ErreurInterne "Paramètre ref attendu")
                else
                  analyse_code_expression e_param
              in
              acc ^ code_param
            ) "" tp le in
            code_params ^ (call "ST" nom) ^ (pop 0 0)
        
        | InfoVar (n, _, _, _, _) | InfoConst (n, _) ->
            raise (ErreurInterne ("AppelProc sur non-fonction: " ^ n))
        | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
            raise (ErreurInterne ("AppelProc sur enum: " ^ n))
      end
  
  | AstPlacement.Empty -> ""


(* analyse_code_bloc : AstPlacement.bloc -> string *)
(* Paramètre bloc : le bloc avec sa taille *)
(* Génère le code du bloc et dépile les variables locales à la fin *)
and analyse_code_bloc (li, taille) =
  let code_instructions = String.concat "" (List.map analyse_code_instruction li) in
  if taille > 0 then
    code_instructions ^ (pop 0 taille)
  else
    code_instructions


(* analyse_code_fonction : AstPlacement.fonction -> string *)
(* Paramètre fonction : la fonction à compiler *)
(* Génère le code de la fonction avec son label et HALT final *)
let analyse_code_fonction (AstPlacement.Fonction (info, _, bloc)) =
  match info_ast_to_info info with
  | InfoFun (nom, _, _) ->
      (label nom) ^ (analyse_code_bloc bloc) ^ (halt)
  | InfoVar (n, _, _, _, _) | InfoConst (n, _) ->
      raise (ErreurInterne ("Fonction sans InfoFun: " ^ n))
  | InfoTypeEnum (n, _) | InfoValeurEnum (n, _, _) ->
      raise (ErreurInterne ("Fonction enum: " ^ n))


(* analyser : AstPlacement.programme -> string *)
(* Paramètre programme : le programme complet *)
(* Génère le code TAM complet avec entête, fonctions et main *)
let analyser (AstPlacement.Programme (fonctions, prog)) =
  let entete = getEntete () in
  let code_fonctions = String.concat "" (List.map analyse_code_fonction fonctions) in
  let label_main = label "main" in
  let code_main = analyse_code_bloc prog in
  entete ^ code_fonctions ^ label_main ^ code_main ^ halt


(* TESTS UNITAIRES - Passe Code TAM *)


let%test_unit "code_expression_entier" =
  let code = analyse_code_expression (AstType.Entier 42) in
  assert (code = "LOADL 42\n")

let%test_unit "code_expression_booleen_true" =
  let code = analyse_code_expression (AstType.Booleen true) in
  assert (code = "LOADL 1\n")

let%test_unit "code_expression_booleen_false" =
  let code = analyse_code_expression (AstType.Booleen false) in
  assert (code = "LOADL 0\n")

let%test_unit "code_expression_null" =
  let code = analyse_code_expression AstType.Null in
  assert (code = "LOADL 0\n")

let%test_unit "code_expression_new_int" =
  let code = analyse_code_expression (AstType.New Int) in
  assert (code = "LOADL 1\nSUBR MAlloc\n")

let%test_unit "code_expression_new_rat" =
  let code = analyse_code_expression (AstType.New Rat) in
  assert (code = "LOADL 2\nSUBR MAlloc\n")

let%test_unit "code_expression_new_pointeur" =
  let code = analyse_code_expression (AstType.New (Pointeur Int)) in
  assert (code = "LOADL 1\nSUBR MAlloc\n")

let%test_unit "code_expression_adresse" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 5, "SB", false)) in
  let code = analyse_code_expression (AstType.Adresse info_x) in
  assert (code = "LOADA 5[SB]\n")

let%test_unit "code_affectable_lecture_var_int" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "SB", false)) in
  let code = analyse_code_affectable (AstTds.Ident info_x) false in
  assert (code = "LOAD (1) 0[SB]\n")

let%test_unit "code_affectable_ecriture_var_int" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "SB", false)) in
  let code = analyse_code_affectable (AstTds.Ident info_x) true in
  assert (code = "LOADA 0[SB]\n")

let%test_unit "code_affectable_lecture_const" =
  let info_c = info_to_info_ast (InfoConst ("c", 42)) in
  let code = analyse_code_affectable (AstTds.Ident info_c) false in
  assert (code = "LOADL 42\n")

let%test_unit "code_affectable_lecture_deref" =
  let info_p = info_to_info_ast (InfoVar ("p", Pointeur Int, 0, "SB", false)) in
  let code = analyse_code_affectable (AstTds.Deref (AstTds.Ident info_p)) false in
  assert (code = "LOAD (1) 0[SB]\nLOADI (1)\n")

let%test_unit "code_affectable_ecriture_deref" =
  let info_p = info_to_info_ast (InfoVar ("p", Pointeur Int, 0, "SB", false)) in
  let code = analyse_code_affectable (AstTds.Deref (AstTds.Ident info_p)) true in
  assert (code = "LOAD (1) 0[SB]\n")

let%test_unit "code_expression_plus_int" =
  let code = analyse_code_expression 
    (AstType.Binaire (AstType.PlusInt, AstType.Entier 1, AstType.Entier 2)) in
  assert (code = "LOADL 1\nLOADL 2\nSUBR IAdd\n")

let%test_unit "code_instruction_declaration" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "SB", false)) in
  let code = analyse_code_instruction 
    (AstPlacement.Declaration (info_x, AstType.Entier 42)) in
  assert (code = "PUSH 1\nLOADL 42\nSTORE (1) 0[SB]\n")

let%test_unit "code_instruction_retour_void" =
  let code = analyse_code_instruction 
    (AstPlacement.RetourVide 3) in
  assert (code = "RETURN (0) 3\n")

let%test_unit "code_bloc_vide" =
  let code = analyse_code_bloc ([], 0) in
  assert (code = "")

let%test_unit "code_expression_ref" =
  let info_x = info_to_info_ast (InfoVar ("x", Int, 5, "SB", false)) in
  let code = analyse_code_expression (AstType.Ref info_x) in
  assert (code = "LOADA 5[SB]\n")

let%test_unit "code_affectable_param_ref_lecture" =
  let info_a = info_to_info_ast (InfoVar ("a", Rat, -1, "LB", true)) in
  let code = analyse_code_affectable (AstTds.Ident info_a) false in
  (* Lecture param ref : LOAD 1 -1[LB] (adresse) puis LOADI 2 (valeur Rat) *)
  assert (code = "LOAD (1) -1[LB]\nLOADI (2)\n")

let%test_unit "code_affectable_param_ref_ecriture" =
  let info_a = info_to_info_ast (InfoVar ("a", Rat, -1, "LB", true)) in
  let code = analyse_code_affectable (AstTds.Ident info_a) true in
  (* Écriture param ref : LOAD 1 -1[LB] (charger l'adresse stockée) *)
  assert (code = "LOAD (1) -1[LB]\n")

(* Test expression valeur enum *)
let%test_unit "code_expression_valeur_enum_rouge" =
  let info_rouge = info_to_info_ast (InfoValeurEnum ("Rouge", "Couleur", 0)) in
  let code = analyse_code_expression (AstType.ValeurEnum info_rouge) in
  assert (code = "LOADL 0\n")  (* Index 0 *)

let%test_unit "code_expression_valeur_enum_bleu" =
  let info_bleu = info_to_info_ast (InfoValeurEnum ("Bleu", "Couleur", 2)) in
  let code = analyse_code_expression (AstType.ValeurEnum info_bleu) in
  assert (code = "LOADL 2\n")  (* Index 2 *)

(* Test déclaration variable enum *)
let%test_unit "code_declaration_enum" =
  let info_c = info_to_info_ast (InfoVar ("c", TypeEnum "Couleur", 0, "SB", false)) in
  let info_rouge = info_to_info_ast (InfoValeurEnum ("Rouge", "Couleur", 0)) in
  let code = analyse_code_instruction 
    (AstPlacement.Declaration (info_c, AstType.ValeurEnum info_rouge)) in
  assert (code = "PUSH 1\nLOADL 0\nSTORE (1) 0[SB]\n")

(* Test affectation enum *)
let%test_unit "code_affectation_enum" =
  let info_c = info_to_info_ast (InfoVar ("c", TypeEnum "Couleur", 0, "SB", false)) in
  let info_bleu = info_to_info_ast (InfoValeurEnum ("Bleu", "Couleur", 1)) in
  let code = analyse_code_instruction 
    (AstPlacement.Affectation (AstTds.Ident info_c, AstType.ValeurEnum info_bleu)) in
  assert (code = "LOADL 1\nLOADA 0[SB]\nSTOREI (1)\n")

(* Test lecture variable enum *)
let%test_unit "code_affectable_lecture_enum" =
  let info_c = info_to_info_ast (InfoVar ("c", TypeEnum "Couleur", 0, "SB", false)) in
  let code = analyse_code_affectable (AstTds.Ident info_c) false in
  assert (code = "LOAD (1) 0[SB]\n")  (* Enum = 1 mot *)

(* Test égalité enums *)
let%test_unit "code_equ_enum" =
  let info_rouge = info_to_info_ast (InfoValeurEnum ("Rouge", "Couleur", 0)) in
  let info_bleu = info_to_info_ast (InfoValeurEnum ("Bleu", "Couleur", 1)) in
  let code = analyse_code_expression 
    (AstType.Binaire (AstType.EquEnum, 
                      AstType.ValeurEnum info_rouge, 
                      AstType.ValeurEnum info_bleu)) in
  assert (code = "LOADL 0\nLOADL 1\nSUBR IEq\n")

(* Test conditionnelle avec enum *)
let%test_unit "code_conditionnelle_enum" =
  let info_c = info_to_info_ast (InfoVar ("c", TypeEnum "Jour", 0, "SB", false)) in
  let info_lundi = info_to_info_ast (InfoValeurEnum ("Lundi", "Jour", 0)) in
  let condition = AstType.Binaire (AstType.EquEnum,
                                   AstType.Affectable (AstTds.Ident info_c),
                                   AstType.ValeurEnum info_lundi) in
  let code = analyse_code_instruction 
    (AstPlacement.Conditionnelle (condition, ([], 0), ([], 0))) in
  (* Vérifier que ça génère du code sans erreur *)
  assert (String.length code > 0)

(* Test paramètre ref enum *)
let%test_unit "code_ref_param_enum" =
  let info_c = info_to_info_ast (InfoVar ("c", TypeEnum "Couleur", -1, "LB", true)) in
  let code = analyse_code_affectable (AstTds.Ident info_c) false in
  (* Paramètre ref enum : LOAD adresse puis LOADI valeur (1 mot) *)
  assert (code = "LOAD (1) -1[LB]\nLOADI (1)\n")

(* Test new avec enum - interdit mais vérifions que getTaille fonctionne *)
let%test_unit "code_new_pointeur_enum" =
  let code = analyse_code_expression (AstType.New (TypeEnum "Couleur")) in
  assert (code = "LOADL 1\nSUBR MAlloc\n")  (* Enum = 1 mot *)

(* Test affectable enum dans déref *)
let%test_unit "code_deref_pointeur_enum" =
  let info_p = info_to_info_ast (InfoVar ("p", Pointeur (TypeEnum "Couleur"), 0, "SB", false)) in
  let code = analyse_code_affectable (AstTds.Deref (AstTds.Ident info_p)) false in
  assert (code = "LOAD (1) 0[SB]\nLOADI (1)\n")  (* Enum = 1 mot *)
