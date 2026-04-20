(* Module de la passe de gestion des identifiants *)
open Tds
open Exceptions
open Ast

type t1 = Ast.AstSyntax.programme
type t2 = Ast.AstTds.programme


(* analyse_tds_enum : tds -> AstSyntax.enum_def -> unit *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre enum_def : la définition d'enum à analyser *)
(* Ajoute un type enum et ses valeurs dans la TDS *)
(* Erreur si double déclaration du type ou d'une valeur *)
let analyse_tds_enum tds (AstSyntax.EnumDef (nom_type, valeurs)) =
  (* Vérifier que le type n'existe pas déjà *)
  match chercherLocalement tds nom_type with
  | Some _ -> raise (DoubleDeclarationEnum nom_type)
  | None ->
      (* Ajouter le type enum *)
      let info_type = InfoTypeEnum (nom_type, valeurs) in
      ajouter tds nom_type (info_to_info_ast info_type);
      
      (* Ajouter chaque valeur avec son index *)
      let _ = List.fold_left (fun index valeur ->
        (* Vérifier que la valeur n'existe pas déjà *)
        match chercherGlobalement tds valeur with
        | Some info ->
            begin
              match info_ast_to_info info with
              | InfoValeurEnum (_, autre_type, _) ->
                  raise (ValeurEnumDejaDeclare (valeur, autre_type))
              | _ -> raise (DoubleDeclaration valeur)
            end
        | None ->
            let info_val = InfoValeurEnum (valeur, nom_type, index) in
            ajouter tds valeur (info_to_info_ast info_val);
            index + 1
      ) 0 valeurs in
      ()


(* analyse_tds_affectable : tds -> AstSyntax.affectable -> bool -> AstTds.affectable *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre a : l'affectable à analyser *)
(* Paramètre is_left : true si partie gauche d'affectation, false sinon *)
(* Vérifie la bonne utilisation des identifiants et transforme l'affectable *)
(* Erreur si mauvaise utilisation des identifiants *)
let rec analyse_tds_affectable tds a is_left =
  match a with
  | AstSyntax.Ident n ->
      begin
        match chercherGlobalement tds n with
        | None -> raise (IdentifiantNonDeclare n)
        | Some info ->
            begin
              match info_ast_to_info info with
              | InfoVar (_, _, _, _, _) -> AstTds.Ident info
              | InfoConst _ ->
                  if is_left then
                    raise (MauvaiseUtilisationIdentifiant n)
                  else
                    AstTds.Ident info
              | InfoFun _ | InfoTypeEnum _ | InfoValeurEnum _ -> 
                  raise (MauvaiseUtilisationIdentifiant n)
            end
      end
  | AstSyntax.Deref a ->
      let na = analyse_tds_affectable tds a false in
      AstTds.Deref na


(* analyse_tds_expression : tds -> AstSyntax.expression -> AstTds.expression *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre e : l'expression à analyser *)
(* Vérifie la bonne utilisation des identifiants et transforme l'expression *)
(* Erreur si mauvaise utilisation des identifiants *)
let rec analyse_tds_expression tds e = 
  match e with
  | AstSyntax.AppelFonction (id, le) ->
      begin
        match chercherGlobalement tds id with
        | None -> raise (IdentifiantNonDeclare id)
        | Some info ->
            begin
              match info_ast_to_info info with
              | InfoFun _ ->
                  let nle = List.map (analyse_tds_expression tds) le in
                  AstTds.AppelFonction (info, nle)
              | _ -> raise (MauvaiseUtilisationIdentifiant id)
            end
      end
  
  | AstSyntax.Affectable a ->
      let na = analyse_tds_affectable tds a false in
      AstTds.Affectable na
  
  | AstSyntax.Binaire (b, e1, e2) ->
      let ne1 = analyse_tds_expression tds e1 in
      let ne2 = analyse_tds_expression tds e2 in
      AstTds.Binaire (b, ne1, ne2)
  
  | AstSyntax.Unaire (op, e1) ->
      let ne1 = analyse_tds_expression tds e1 in
      AstTds.Unaire (op, ne1)
  
  | AstSyntax.Booleen b -> AstTds.Booleen b
  | AstSyntax.Entier i -> AstTds.Entier i
  | AstSyntax.Null -> AstTds.Null
  | AstSyntax.New t -> AstTds.New t
  
  | AstSyntax.Adresse n ->
      begin
        match chercherGlobalement tds n with
        | None -> raise (IdentifiantNonDeclare n)
        | Some info ->
            begin
              match info_ast_to_info info with
              | InfoVar _ -> AstTds.Adresse info
              | _ -> raise (MauvaiseUtilisationIdentifiant n)
            end
      end
 
  | AstSyntax.Ref n ->
      begin
        match chercherGlobalement tds n with
        | None -> raise (IdentifiantNonDeclare n)
        | Some info ->
            begin
              match info_ast_to_info info with
              | InfoVar _ -> AstTds.Ref info
              | _ -> raise (MauvaiseUtilisationIdentifiant n)
            end
      end
  
  | AstSyntax.ValeurEnum v ->
      begin
        match chercherGlobalement tds v with
        | None -> raise (ValeurEnumInconnue v)
        | Some info ->
            begin
              match info_ast_to_info info with
              | InfoValeurEnum _ -> AstTds.ValeurEnum info
              | _ -> raise (MauvaiseUtilisationIdentifiant v)
            end
      end


(* analyse_tds_instruction : tds -> info_ast option -> AstSyntax.instruction -> AstTds.instruction *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre oia : None si l'instruction est dans le bloc principal,
                   Some ia où ia est l'information associée à la fonction sinon *)
(* Paramètre i : l'instruction à analyser *)
(* Vérifie la bonne utilisation des identifiants et transforme l'instruction *)
(* Erreur si mauvaise utilisation des identifiants *)
let rec analyse_tds_instruction tds oia i =
  match i with
  | AstSyntax.Declaration (t, n, e) ->
      begin
        match chercherLocalement tds n with
        | None ->
            let ne = analyse_tds_expression tds e in
            let info = InfoVar (n, Undefined, 0, "", false) in
            let ia = info_to_info_ast info in
            ajouter tds n ia;
            AstTds.Declaration (t, ia, ne)
        | Some _ ->
            raise (DoubleDeclaration n)
      end
  
  | AstSyntax.Affectation (a, e) ->
      let na = analyse_tds_affectable tds a true in
      let ne = analyse_tds_expression tds e in
      AstTds.Affectation (na, ne)
  
  | AstSyntax.Constante (n, v) ->
      begin
        match chercherLocalement tds n with
        | None ->
            ajouter tds n (info_to_info_ast (InfoConst (n, v)));
            AstTds.Empty
        | Some _ ->
            raise (DoubleDeclaration n)
      end
  
  | AstSyntax.Affichage e ->
      let ne = analyse_tds_expression tds e in
      AstTds.Affichage ne
  
  | AstSyntax.Conditionnelle (c, t, e) ->
      let nc = analyse_tds_expression tds c in
      let tast = analyse_tds_bloc tds oia t in
      let east = analyse_tds_bloc tds oia e in
      AstTds.Conditionnelle (nc, tast, east)
  
  | AstSyntax.TantQue (c, b) ->
      let nc = analyse_tds_expression tds c in
      let bast = analyse_tds_bloc tds oia b in
      AstTds.TantQue (nc, bast)
  
  | AstSyntax.Retour e ->
      begin
        match oia with
        | None -> raise RetourDansMain
        | Some ia ->
            let ne = analyse_tds_expression tds e in
            AstTds.Retour (ne, ia)
      end
  
  | AstSyntax.RetourVide ->
      begin
        match oia with
        | None -> raise RetourDansMain
        | Some ia -> AstTds.RetourVide ia
      end
  
  | AstSyntax.AppelProc (id, le) ->
      begin
        match chercherGlobalement tds id with
        | None -> raise (IdentifiantNonDeclare id)
        | Some info ->
            begin
              match info_ast_to_info info with
              | InfoFun _ ->
                  let nle = List.map (analyse_tds_expression tds) le in
                  AstTds.AppelProc (info, nle)
              | _ -> raise (MauvaiseUtilisationIdentifiant id)
            end
      end


(* analyse_tds_bloc : tds -> info_ast option -> AstSyntax.bloc -> AstTds.bloc *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre oia : None si le bloc est dans le programme principal,
                   Some ia où ia est l'information associée à la fonction sinon *)
(* Paramètre li : liste d'instructions à analyser *)
(* Vérifie la bonne utilisation des identifiants et transforme le bloc *)
(* Erreur si mauvaise utilisation des identifiants *)
and analyse_tds_bloc tds oia li =
  let tdsbloc = creerTDSFille tds in
  let nli = List.map (analyse_tds_instruction tdsbloc oia) li in
  nli


(* analyse_tds_fonction : tds -> AstSyntax.fonction -> AstTds.fonction *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre : la fonction à analyser *)
(* Vérifie la bonne utilisation des identifiants et transforme la fonction *)
(* Erreur si mauvaise utilisation des identifiants *)
let analyse_tds_fonction maintds (AstSyntax.Fonction(t, n, lp, li)) =
  begin
    match chercherLocalement maintds n with
    | Some _ -> raise (DoubleDeclaration n)
    | None ->
        let info = InfoFun (n, Undefined, []) in
        let ia = info_to_info_ast info in
        ajouter maintds n ia;
        
        let tdsfonc = creerTDSFille maintds in
        
        let nlp = List.map (fun (tp, is_ref, np) ->
          match chercherLocalement tdsfonc np with
          | Some _ -> raise (DoubleDeclaration np)
          | None ->
              let infop = InfoVar (np, Undefined, 0, "", is_ref) in
              let iap = info_to_info_ast infop in
              ajouter tdsfonc np iap;
              (tp, is_ref, iap)
        ) lp in
        
        let nli = analyse_tds_bloc tdsfonc (Some ia) li in
        
        AstTds.Fonction (t, ia, nlp, nli)
  end


(* analyser : AstSyntax.programme -> AstTds.programme *)
(* Paramètre : le programme à analyser *)
(* Vérifie la bonne utilisation des identifiants et transforme le programme *)
(* Erreur si mauvaise utilisation des identifiants *)
let analyser (AstSyntax.Programme (enums, fonctions, prog)) =
  let tds = creerTDSMere () in
  
  (* Analyser les enums en premier *)
  List.iter (analyse_tds_enum tds) enums;
  
  (* Puis les fonctions et le programme *)
  let nf = List.map (analyse_tds_fonction tds) fonctions in
  let nb = analyse_tds_bloc tds None prog in
  AstTds.Programme (nf, nb)


(* Tests unitaires de la 1ère passe *)

(* Tests analyse_tds_affectable - lecture variable *)
let%test_unit "tds_affectable_var_lecture" =
  let tds = creerTDSMere () in
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "SB", false)) in
  ajouter tds "x" info_x;
  let resultat = analyse_tds_affectable tds (AstSyntax.Ident "x") false in
  match resultat with
  | AstTds.Ident i -> assert (i = info_x)
  | _ -> assert false

(* Tests analyse_tds_affectable - écriture variable *)
let%test_unit "tds_affectable_var_ecriture" =
  let tds = creerTDSMere () in
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "SB", false)) in
  ajouter tds "x" info_x;
  let resultat = analyse_tds_affectable tds (AstSyntax.Ident "x") true in
  match resultat with
  | AstTds.Ident i -> assert (i = info_x)
  | _ -> assert false

(* Tests analyse_tds_affectable - lecture constante OK *)
let%test_unit "tds_affectable_const_lecture" =
  let tds = creerTDSMere () in
  let info_c = info_to_info_ast (InfoConst ("c", 42)) in
  ajouter tds "c" info_c;
  let resultat = analyse_tds_affectable tds (AstSyntax.Ident "c") false in
  match resultat with
  | AstTds.Ident i -> assert (i = info_c)
  | _ -> assert false

(* Tests analyse_tds_affectable - écriture constante interdite *)
let%test_unit "tds_affectable_const_ecriture_erreur" =
  let tds = creerTDSMere () in
  let info_c = info_to_info_ast (InfoConst ("c", 42)) in
  ajouter tds "c" info_c;
  try
    let _ = analyse_tds_affectable tds (AstSyntax.Ident "c") true in
    assert false
  with
  | MauvaiseUtilisationIdentifiant "c" -> ()
  | _ -> assert false

(* Tests analyse_tds_affectable - fonction interdite *)
let%test_unit "tds_affectable_fonction_erreur" =
  let tds = creerTDSMere () in
  let info_f = info_to_info_ast (InfoFun ("f", Int, [(Int, false)])) in
  ajouter tds "f" info_f;
  try
    let _ = analyse_tds_affectable tds (AstSyntax.Ident "f") false in
    assert false
  with
  | MauvaiseUtilisationIdentifiant "f" -> ()
  | _ -> assert false

(* Tests analyse_tds_affectable - déréférencement *)
let%test_unit "tds_affectable_deref" =
  let tds = creerTDSMere () in
  let info_p = info_to_info_ast (InfoVar ("p", Pointeur Int, 0, "SB", false)) in
  ajouter tds "p" info_p;
  let resultat = analyse_tds_affectable tds (AstSyntax.Deref (AstSyntax.Ident "p")) false in
  match resultat with
  | AstTds.Deref (AstTds.Ident i) -> assert (i = info_p)
  | _ -> assert false

(* Tests analyse_tds_affectable - déréférencement multiple *)
let%test_unit "tds_affectable_deref_multiple" =
  let tds = creerTDSMere () in
  let info_pp = info_to_info_ast (InfoVar ("pp", Pointeur (Pointeur Int), 0, "SB", false)) in
  ajouter tds "pp" info_pp;
  let resultat = analyse_tds_affectable tds 
    (AstSyntax.Deref (AstSyntax.Deref (AstSyntax.Ident "pp"))) false in
  match resultat with
  | AstTds.Deref (AstTds.Deref (AstTds.Ident i)) -> assert (i = info_pp)
  | _ -> assert false

(* Tests analyse_tds_affectable - identifiant non déclaré *)
let%test_unit "tds_affectable_non_declare" =
  let tds = creerTDSMere () in
  try
    let _ = analyse_tds_affectable tds (AstSyntax.Ident "x") false in
    assert false
  with
  | IdentifiantNonDeclare "x" -> ()
  | _ -> assert false

(* Tests analyse_tds_expression - entier *)
let%test_unit "tds_expression_entier" =
  let tds = creerTDSMere () in
  let resultat = analyse_tds_expression tds (AstSyntax.Entier 42) in
  match resultat with
  | AstTds.Entier 42 -> ()
  | _ -> assert false

(* Tests analyse_tds_expression - booléen *)
let%test_unit "tds_expression_booleen" =
  let tds = creerTDSMere () in
  let resultat = analyse_tds_expression tds (AstSyntax.Booleen true) in
  match resultat with
  | AstTds.Booleen true -> ()
  | _ -> assert false

(* Tests analyse_tds_expression - null *)
let%test_unit "tds_expression_null" =
  let tds = creerTDSMere () in
  let resultat = analyse_tds_expression tds AstSyntax.Null in
  match resultat with
  | AstTds.Null -> ()
  | _ -> assert false

(* Tests analyse_tds_expression - new *)
let%test_unit "tds_expression_new" =
  let tds = creerTDSMere () in
  let resultat = analyse_tds_expression tds (AstSyntax.New Int) in
  match resultat with
  | AstTds.New Int -> ()
  | _ -> assert false

(* Tests analyse_tds_expression - adresse *)
let%test_unit "tds_expression_adresse" =
  let tds = creerTDSMere () in
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "SB", false)) in
  ajouter tds "x" info_x;
  let resultat = analyse_tds_expression tds (AstSyntax.Adresse "x") in
  match resultat with
  | AstTds.Adresse i -> assert (i = info_x)
  | _ -> assert false

(* Tests analyse_tds_expression - adresse sur constante interdite *)
let%test_unit "tds_expression_adresse_constante_erreur" =
  let tds = creerTDSMere () in
  let info_c = info_to_info_ast (InfoConst ("c", 42)) in
  ajouter tds "c" info_c;
  try
    let _ = analyse_tds_expression tds (AstSyntax.Adresse "c") in
    assert false
  with
  | MauvaiseUtilisationIdentifiant "c" -> ()
  | _ -> assert false

(* Tests analyse_tds_expression - appel fonction *)
let%test_unit "tds_expression_appel_fonction" =
  let tds = creerTDSMere () in
  let info_f = info_to_info_ast (InfoFun ("f", Int, [(Int, false)])) in
  ajouter tds "f" info_f;
  let resultat = analyse_tds_expression tds 
    (AstSyntax.AppelFonction ("f", [AstSyntax.Entier 42])) in
  match resultat with
  | AstTds.AppelFonction (i, [AstTds.Entier 42]) -> assert (i = info_f)
  | _ -> assert false

(* Tests analyse_tds_expression - appel non-fonction *)
let%test_unit "tds_expression_appel_variable_erreur" =
  let tds = creerTDSMere () in
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "SB", false)) in
  ajouter tds "x" info_x;
  try
    let _ = analyse_tds_expression tds (AstSyntax.AppelFonction ("x", [])) in
    assert false
  with
  | MauvaiseUtilisationIdentifiant "x" -> ()
  | _ -> assert false

(* Test ref id dans expressions *)
let%test_unit "tds_expression_ref" =
  let tds = creerTDSMere () in
  let info_x = info_to_info_ast (InfoVar ("x", Int, 0, "SB", false)) in
  ajouter tds "x" info_x;
  let resultat = analyse_tds_expression tds (AstSyntax.Ref "x") in
  match resultat with
  | AstTds.Ref i -> assert (i = info_x)
  | _ -> assert false

(* test ref sur constante interdit *)
let%test_unit "tds_expression_ref_constante_erreur" =
  let tds = creerTDSMere () in
  let info_c = info_to_info_ast (InfoConst ("c", 42)) in
  ajouter tds "c" info_c;
  try
    let _ = analyse_tds_expression tds (AstSyntax.Ref "c") in
    assert false
  with
  | MauvaiseUtilisationIdentifiant "c" -> ()
  | _ -> assert false

(* Test ref sur fonction interdit *)
let%test_unit "tds_expression_ref_fonction_erreur" =
  let tds = creerTDSMere () in
  let info_f = info_to_info_ast (InfoFun ("f", Int, [])) in
  ajouter tds "f" info_f;
  try
    let _ = analyse_tds_expression tds (AstSyntax.Ref "f") in
    assert false
  with
  | MauvaiseUtilisationIdentifiant "f" -> ()
  | _ -> assert false

(* Test fonction avec paramètre ref *)
let%test_unit "tds_fonction_param_ref" =
  let tds = creerTDSMere () in
  let fonction = AstSyntax.Fonction (
    Int, 
    "f", 
    [(Int, true, "a"); (Int, false, "b")],
    []
  ) in
  let _ = analyse_tds_fonction tds fonction in
  match chercherGlobalement tds "f" with
  | Some info ->
      begin
        match info_ast_to_info info with
        | InfoFun (_, _, _) -> ()
        | _ -> assert false
      end
  | None -> assert false

(* Test double déclaration paramètre ref *)
let%test_unit "tds_fonction_double_param_ref" =
  let tds = creerTDSMere () in
  let fonction = AstSyntax.Fonction (
    Int, 
    "f", 
    [(Int, true, "a"); (Int, false, "a")],  (* même nom ! *)
    []
  ) in
  try
    let _ = analyse_tds_fonction tds fonction in
    assert false
  with
  | DoubleDeclaration "a" -> ()
  | _ -> assert false

  
(* Test enum simple *)
let%test_unit "tds_enum_simple" =
  let tds = creerTDSMere () in
  let enum_def = AstSyntax.EnumDef ("Couleur", ["Rouge"; "Vert"; "Bleu"]) in
  analyse_tds_enum tds enum_def;
  match chercherLocalement tds "Couleur" with
  | Some info ->
      begin
        match info_ast_to_info info with
        | InfoTypeEnum ("Couleur", ["Rouge"; "Vert"; "Bleu"]) -> ()
        | _ -> assert false
      end
  | None -> assert false

(* Test valeurs enum ajoutées *)
let%test_unit "tds_enum_valeurs" =
  let tds = creerTDSMere () in
  let enum_def = AstSyntax.EnumDef ("Jour", ["Lundi"; "Mardi"]) in
  analyse_tds_enum tds enum_def;
  match chercherLocalement tds "Lundi" with
  | Some info ->
      begin
        match info_ast_to_info info with
        | InfoValeurEnum ("Lundi", "Jour", 0) -> ()
        | _ -> assert false
      end
  | None -> assert false

(* Test double déclaration enum *)
let%test_unit "tds_enum_double_declaration" =
  let tds = creerTDSMere () in
  let enum1 = AstSyntax.EnumDef ("Couleur", ["Rouge"]) in
  let enum2 = AstSyntax.EnumDef ("Couleur", ["Bleu"]) in
  analyse_tds_enum tds enum1;
  try
    analyse_tds_enum tds enum2;
    assert false
  with
  | DoubleDeclarationEnum "Couleur" -> ()
  | _ -> assert false

(* Test valeur enum déjà déclarée *)
let%test_unit "tds_enum_valeur_deja_declaree" =
  let tds = creerTDSMere () in
  let enum1 = AstSyntax.EnumDef ("Couleur", ["Rouge"]) in
  let enum2 = AstSyntax.EnumDef ("Teinte", ["Rouge"]) in
  analyse_tds_enum tds enum1;
  try
    analyse_tds_enum tds enum2;
    assert false
  with
  | ValeurEnumDejaDeclare ("Rouge", "Couleur") -> ()
  | _ -> assert false

(* Test expression ValeurEnum *)
let%test_unit "tds_expression_valeur_enum" =
  let tds = creerTDSMere () in
  let enum_def = AstSyntax.EnumDef ("Couleur", ["Rouge"]) in
  analyse_tds_enum tds enum_def;
  let expr = AstSyntax.ValeurEnum "Rouge" in
  let resultat = analyse_tds_expression tds expr in
  match resultat with
  | AstTds.ValeurEnum info ->
      begin
        match info_ast_to_info info with
        | InfoValeurEnum ("Rouge", "Couleur", 0) -> ()
        | _ -> assert false
      end
  | _ -> assert false

(* Test valeur enum inconnue *)
let%test_unit "tds_valeur_enum_inconnue" =
  let tds = creerTDSMere () in
  try
    let _ = analyse_tds_expression tds (AstSyntax.ValeurEnum "Inexistant") in
    assert false
  with
  | ValeurEnumInconnue "Inexistant" -> ()
  | _ -> assert false