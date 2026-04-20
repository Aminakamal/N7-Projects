open Hashtbl
open Type

(* Définition du type des informations associées aux identifiants *)
type info =
  | InfoConst of string * int
  | InfoVar of string * typ * int * string * bool
  | InfoFun of string * typ * (typ * bool) list
  | InfoTypeEnum of string * string list  (* nom_type, [valeurs] *)
  | InfoValeurEnum of string * string * int  (* nom_valeur, nom_type, index *)

(* Données stockées dans la tds et dans les AST : pointeur sur une information *)
type info_ast = info ref  

(* Table des symboles hiérarchique *)
type tds =
  | Nulle
  | Courante of tds * (string, info_ast) Hashtbl.t


(* Créer une information à associer à l'AST à partir d'une info *)
let info_to_info_ast i = ref i

(* Récupère l'information associée à un noeud *)
let info_ast_to_info i = !i

(* Création d'une table des symboles à la racine *)
let creerTDSMere () = Courante (Nulle, Hashtbl.create 100)

(* Création d'une table des symboles fille *)
let creerTDSFille mere = Courante (mere, Hashtbl.create 100)


(* Ajoute une information dans la table des symboles locale *)
let ajouter tds nom info =
  match tds with
  | Nulle -> failwith "Ajout dans une table vide"
  | Courante (_, c) -> Hashtbl.add c nom info

(* Recherche les informations d'un identificateur dans la tds locale *)
let chercherLocalement tds nom =
  match tds with
  | Nulle -> None
  | Courante (_, c) -> find_opt c nom 

(* Recherche les informations d'un identificateur dans la tds globale *)
let rec chercherGlobalement tds nom =
  match tds with
  | Nulle -> None
  | Courante (m, c) ->
    match find_opt c nom with
      | Some _ as i -> i
      | None -> chercherGlobalement m nom 


(* Convertie une info en une chaîne de caractère *)
let string_of_info info =
  match info with
  | InfoConst (n, value) -> 
      "Constante " ^ n ^ " : " ^ (string_of_int value)
  | InfoVar (n, t, dep, base, is_ref) -> 
      let ref_str = if is_ref then "ref " else "" in
      "Variable " ^ ref_str ^ n ^ " : " ^ (string_of_type t) ^ " " ^ 
      (string_of_int dep) ^ "[" ^ base ^ "]"
  | InfoFun (n, t, tp) -> 
      let params_str = String.concat " * " (List.map (fun (typ, is_ref) ->
        (if is_ref then "ref " else "") ^ (string_of_type typ)
      ) tp) in
      "Fonction " ^ n ^ " : " ^ params_str ^ " -> " ^ (string_of_type t)
  | InfoTypeEnum (n, valeurs) ->
      "TypeEnum " ^ n ^ " {" ^ (String.concat ", " valeurs) ^ "}"
  | InfoValeurEnum (nom, type_nom, index) ->
      "ValeurEnum " ^ nom ^ " : " ^ type_nom ^ " [" ^ (string_of_int index) ^ "]"

(* Affiche la tds locale *)
let afficher_locale tds =
  match tds with
  | Nulle -> print_newline ()
  | Courante (_, c) -> 
      Hashtbl.iter (fun n info -> 
        print_string (n ^ " : " ^ (string_of_info (info_ast_to_info info)) ^ "\n")
      ) c

(* Affiche la tds locale et récursivement *)
let afficher_globale tds =
  let rec afficher tds indent =
    match tds with
    | Nulle -> print_newline ()
    | Courante (m, c) -> 
        if Hashtbl.length c = 0
        then print_string (indent ^ "<empty>\n")
        else Hashtbl.iter (fun n info -> 
          print_string (indent ^ n ^ " : " ^ (string_of_info (info_ast_to_info info)) ^ "\n")
        ) c; 
        afficher m (indent ^ "  ")
  in afficher tds ""

(* Modifie le type si c'est une InfoVar *)
let modifier_type_variable t i =
  match !i with
  | InfoVar (n, _, dep, base, is_ref) -> i := InfoVar (n, t, dep, base, is_ref)
  | _ -> failwith "Appel modifier_type_variable pas sur un InfoVar"

(* Modifie les types de retour et des paramètres si c'est une InfoFun *)
let modifier_type_fonction t tp i =
  match !i with
  | InfoFun (n, _, _) -> i := InfoFun (n, t, tp)
  | _ -> failwith "Appel modifier_type_fonction pas sur un InfoFun"

(* Modifie l'emplacement si c'est une InfoVar *)
let modifier_adresse_variable d b i =
  match !i with
  | InfoVar (n, t, _, _, is_ref) -> i := InfoVar (n, t, d, b, is_ref)
  | _ -> failwith "Appel modifier_adresse_variable pas sur un InfoVar"


(* TESTS UNITAIRES *)

let%test _ = chercherLocalement (creerTDSMere()) "x" = None

let%test _ = 
  let tds = creerTDSMere() in
  let ix = info_to_info_ast (InfoVar ("x", Rat, 0, "SB", false)) in
  let iy = info_to_info_ast (InfoVar ("y", Int, 2, "SB", false)) in
  ajouter tds "x" ix;
  ajouter tds "y" iy;
  chercherLocalement tds "x" = Some ix

let%test _ = 
  let tds = creerTDSMere() in
  let ix = info_to_info_ast (InfoVar ("x", Rat, 0, "SB", false)) in
  let iy = info_to_info_ast (InfoVar ("y", Int, 2, "SB", false)) in
  ajouter tds "x" ix;
  ajouter tds "y" iy;
  chercherLocalement tds "y" = Some iy

let%test _ = 
  let tds = creerTDSMere() in
  let ix = info_to_info_ast (InfoVar ("x", Rat, 0, "SB", false)) in
  let iy = info_to_info_ast (InfoVar ("y", Int, 2, "SB", false)) in
  ajouter tds "x" ix;
  ajouter tds "y" iy;
  chercherLocalement tds "z" = None

let%test _ = 
  let tds = creerTDSMere() in
  let ix = info_to_info_ast (InfoVar ("x", Rat, 0, "SB", false)) in
  let iy = info_to_info_ast (InfoVar ("y", Int, 2, "SB", false)) in
  ajouter tds "x" ix;
  ajouter tds "y" iy;
  let tdsf = creerTDSFille tds in
  let ix2 = info_to_info_ast (InfoVar ("x", Bool, 3, "LB", false)) in
  let iz = info_to_info_ast (InfoVar ("z", Rat, 4, "LB", false)) in
  ajouter tdsf "x" ix2;
  ajouter tdsf "z" iz;
  chercherLocalement tds "x" = Some ix

let%test _ = 
  let tds = creerTDSMere() in
  let ix = info_to_info_ast (InfoVar ("x", Rat, 0, "SB", false)) in
  let iy = info_to_info_ast (InfoVar ("y", Int, 2, "SB", false)) in
  ajouter tds "x" ix;
  ajouter tds "y" iy;
  let tdsf = creerTDSFille tds in
  let ix2 = info_to_info_ast (InfoVar ("x", Bool, 3, "LB", false)) in
  let iz = info_to_info_ast (InfoVar ("z", Rat, 4, "LB", false)) in
  ajouter tdsf "x" ix2;
  ajouter tdsf "z" iz;
  chercherGlobalement tdsf "x" = Some ix2

let%test _ = 
  let tds = creerTDSMere() in
  let ix = info_to_info_ast (InfoVar ("x", Rat, 0, "SB", false)) in
  let iy = info_to_info_ast (InfoVar ("y", Int, 2, "SB", false)) in
  ajouter tds "x" ix;
  ajouter tds "y" iy;
  let tdsf = creerTDSFille tds in
  let ix2 = info_to_info_ast (InfoVar ("x", Bool, 3, "LB", false)) in
  let iz = info_to_info_ast (InfoVar ("z", Rat, 4, "LB", false)) in
  ajouter tdsf "x" ix2;
  ajouter tdsf "z" iz;
  chercherGlobalement tdsf "y" = Some iy

let%test _ = 
  let info = InfoVar ("x", Undefined, 4, "SB", false) in
  let ia = info_to_info_ast info in
  modifier_type_variable Rat ia;
  match info_ast_to_info ia with
  | InfoVar ("x", Rat, 4, "SB", false) -> true
  | _ -> false

let%test _ = 
  let info = InfoFun ("f", Undefined, []) in
  let ia = info_to_info_ast info in
  modifier_type_fonction Rat [(Int, false); (Int, false)] ia;
  match info_ast_to_info ia with
  | InfoFun ("f", Rat, [(Int, false); (Int, false)]) -> true
  | _ -> false

let%test _ = 
  let info = InfoVar ("x", Rat, 4, "SB", false) in
  let ia = info_to_info_ast info in
  modifier_adresse_variable 10 "LB" ia;
  match info_ast_to_info ia with
  | InfoVar ("x", Rat, 10, "LB", false) -> true
  | _ -> false

(* Tests spécifiques : paramètres ref *)
let%test _ = 
  let info = InfoVar ("a", Int, -1, "LB", true) in
  let ia = info_to_info_ast info in
  match info_ast_to_info ia with
  | InfoVar (_, _, _, _, true) -> true
  | _ -> false

let%test _ = 
  let info = InfoFun ("f", Int, [(Int, true); (Int, false)]) in
  let ia = info_to_info_ast info in
  match info_ast_to_info ia with
  | InfoFun (_, _, [(Int, true); (Int, false)]) -> true
  | _ -> false

(* Tests Enum *)
let%test _ =
  let tds = creerTDSMere() in
  let info_type = info_to_info_ast (InfoTypeEnum ("Couleur", ["Rouge"; "Vert"; "Bleu"])) in
  ajouter tds "Couleur" info_type;
  chercherLocalement tds "Couleur" = Some info_type

let%test _ =
  let tds = creerTDSMere() in
  let info_val = info_to_info_ast (InfoValeurEnum ("Rouge", "Couleur", 0)) in
  ajouter tds "Rouge" info_val;
  match chercherLocalement tds "Rouge" with
  | Some i -> (match info_ast_to_info i with
              | InfoValeurEnum (_, _, 0) -> true
              | _ -> false)
  | None -> false

let%test _ =
  let info = InfoTypeEnum ("Jour", ["Lundi"; "Mardi"]) in
  let ia = info_to_info_ast info in
  match info_ast_to_info ia with
  | InfoTypeEnum ("Jour", _) -> true
  | _ -> false