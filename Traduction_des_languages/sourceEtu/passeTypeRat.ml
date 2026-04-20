(* Module de la passe de typage *)
open Tds
open Exceptions
open Ast
open Type

type t1 = Ast.AstTds.programme
type t2 = Ast.AstType.programme

(* analyse_type_expression : AstTds.expression -> (AstType.expression * typ) *)
let rec analyse_type_expression e =
  match e with
  | AstTds.AppelFonction (info, le) ->
      begin
        match info_ast_to_info info with
        | InfoFun (_, tr, tp) ->
            (* Analyse des paramètres et vérification de la compatibilité [cite: 119-120] *)
            let nle_types = List.map analyse_type_expression le in
            let nle = List.map fst nle_types in
            let types_reels = List.map snd nle_types in
            if est_compatible_list tp types_reels then
              (AstType.AppelFonction (info, nle), tr)
            else
              raise (TypesParametresInattendus (types_reels, tp))
        | _ -> failwith "Internal error: AppelFonction sans InfoFun"
      end
  | AstTds.Ident info ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, t, _, _) -> (AstType.Ident info, t)
        | InfoConst (_, v) -> (AstType.Entier v, Int) (* Transformation de constante en entier [cite: 47] *)
        | _ -> failwith "Internal error: Ident sans InfoVar/InfoConst"
      end
  | AstTds.Booleen b -> (AstType.Booleen b, Bool)
  | AstTds.Entier i -> (AstType.Entier i, Int)
  | AstTds.Unaire (op, e1) ->
      let (ne1, t1) = analyse_type_expression e1 in
      begin
        match op with
        | AstSyntax.Numerateur ->
            if est_compatible Rat t1 then (AstType.Unaire (AstType.Numerateur, ne1), Int)
            else raise (TypeInattendu (t1, Rat))
        | AstSyntax.Denominateur ->
            if est_compatible Rat t1 then (AstType.Unaire (AstType.Denominateur, ne1), Int)
            else raise (TypeInattendu (t1, Rat))
      end
  | AstTds.Binaire (b, e1, e2) ->
      let (ne1, t1) = analyse_type_expression e1 in
      let (ne2, t2) = analyse_type_expression e2 in
      begin
        match b with
        | AstSyntax.Fraction ->
            if est_compatible Int t1 && est_compatible Int t2 then (AstType.Binaire (AstType.Fraction, ne1, ne2), Rat)
            else raise (TypeBinaireInattendu (b, t1, t2))
        | AstSyntax.Plus ->
            if est_compatible Int t1 && est_compatible Int t2 then (AstType.Binaire (AstType.PlusInt, ne1, ne2), Int)
            else if est_compatible Rat t1 && est_compatible Rat t2 then (AstType.Binaire (AstType.PlusRat, ne1, ne2), Rat)
            else raise (TypeBinaireInattendu (b, t1, t2))
        | AstSyntax.Mult ->
            if est_compatible Int t1 && est_compatible Int t2 then (AstType.Binaire (AstType.MultInt, ne1, ne2), Int)
            else if est_compatible Rat t1 && est_compatible Rat t2 then (AstType.Binaire (AstType.MultRat, ne1, ne2), Rat)
            else raise (TypeBinaireInattendu (b, t1, t2))
        | AstSyntax.Equ ->
            if est_compatible Int t1 && est_compatible Int t2 then (AstType.Binaire (AstType.EquInt, ne1, ne2), Bool)
            else if est_compatible Bool t1 && est_compatible Bool t2 then (AstType.Binaire (AstType.EquBool, ne1, ne2), Bool)
            else raise (TypeBinaireInattendu (b, t1, t2))
        | AstSyntax.Inf ->
            if est_compatible Int t1 && est_compatible Int t2 then (AstType.Binaire (AstType.Inf, ne1, ne2), Bool)
            else raise (TypeBinaireInattendu (b, t1, t2))
      end

(* analyse_type_instruction : AstTds.instruction -> AstType.instruction *)
let rec analyse_type_instruction i =
  match i with
  | AstTds.Declaration (t, info, e) ->
      let (ne, te) = analyse_type_expression e in
      if est_compatible t te then
        (modifier_type_variable t info; AstType.Declaration (info, ne))
      else raise (TypeInattendu (te, t))
  | AstTds.Affectation (info, e) ->
      begin
        match info_ast_to_info info with
        | InfoVar (_, t, _, _) ->
            let (ne, te) = analyse_type_expression e in
            if est_compatible t te then AstType.Affectation (info, ne)
            else raise (TypeInattendu (te, t))
        | _ -> failwith "Internal error: Affectation sans InfoVar"
      end
  | AstTds.Affichage e ->
      let (ne, te) = analyse_type_expression e in
      begin
        match te with
        | Int -> AstType.AffichageInt ne
        | Rat -> AstType.AffichageRat ne
        | Bool -> AstType.AffichageBool ne
        | Undefined -> failwith "Internal error: type Undefined"
      end
  | AstTds.Conditionnelle (c, t, e) ->
      let (nc, tc) = analyse_type_expression c in
      if est_compatible Bool tc then
        AstType.Conditionnelle (nc, analyse_type_bloc t, analyse_type_bloc e)
      else raise (TypeInattendu (tc, Bool))
  | AstTds.TantQue (c, b) ->
      let (nc, tc) = analyse_type_expression c in
      if est_compatible Bool tc then AstType.TantQue (nc, analyse_type_bloc b)
      else raise (TypeInattendu (tc, Bool))
  | AstTds.Retour (e, info) ->
      begin
        match info_ast_to_info info with
        | InfoFun (_, tr, _) ->
            let (ne, te) = analyse_type_expression e in
            if est_compatible tr te then AstType.Retour (ne, info)
            else raise (TypeInattendu (te, tr))
        | _ -> failwith "Internal error: Retour sans InfoFun"
      end
  | AstTds.Empty -> AstType.Empty

and analyse_type_bloc li = List.map analyse_type_instruction li

(* analyse_type_fonction : AstTds.fonction -> AstType.fonction *)
let analyse_type_fonction (AstTds.Fonction (t, info, lp, li)) =
  (* Mise à jour du type des paramètres dans leurs infos respectives [cite: 131-134] *)
  let nlp = List.map (fun (tp, infop) -> modifier_type_variable tp infop; infop) lp in
  (* Extraction des types pour l'info globale de la fonction  *)
  let types_params = List.map fst lp in
  modifier_type_fonction t types_params info;
  let nli = analyse_type_bloc li in
  AstType.Fonction (info, nlp, nli)

(* analyser : AstTds.programme -> AstType.programme *)
let analyser (AstTds.Programme (fonctions, prog)) =
  let nf = List.map analyse_type_fonction fonctions in
  let nb = analyse_type_bloc prog in
  AstType.Programme (nf, nb)