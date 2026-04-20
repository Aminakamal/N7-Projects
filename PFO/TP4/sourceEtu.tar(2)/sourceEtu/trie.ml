open Arbre
open Chaines

(* le type trie :
    triplet arbre,
            fonction de décomposition mot -> liste de caractères,
            fonction de recomposition liste de caractères -> mot *)
type ('a,'b) trie = Trie of ('b arbre) * ('a -> 'b list) * ('b list -> 'a)

(* Pour les tests *)
let trie_sujet = Trie (arbre_sujet, decompose_chaine, recompose_chaine)
let trie_vide = Trie ( Noeud (false,[]), decompose_chaine, recompose_chaine)
let trie_presque_vide = Trie ( Noeud (true,[]), decompose_chaine, recompose_chaine)


(******************************************************************************)
(*   fonction de création d'un nouveau trie                                   *)
(*   signature  : nouveau :                                                   *)
(*          ('a -> 'b list) -> ('b list -> 'a) -> ('a, 'b) trie = <fun>       *)
(*   paramètres : - une fonction de décomposition                             *)
(*                     mot -> liste de caractères                             *)
(*                -  une fonction de recomposition                            *)
(*                     liste de caractères -> mot                             *)
(*   résultat     : un nouveau trie "vide"                                    *)
(******************************************************************************)
let nouveau fd fr = Trie(Noeud(false,[]), fd, fr)

(******************************************************************************)
(*   fonction d'appartenance d'un élément à un trie                           *)
(*   signature  : appartient : 'a -> ('a, 'b) trie -> bool = <fun>            *)
(*   paramètres : - un mot                                                    *)
(*                - un trie                                                   *)
(*   résultat   : le résultat booléen du test                                 *)
(******************************************************************************)
let appartient m (Trie(arb,fdec,frec)) =
  appartient_arbre (fdec m) arb

(*
let%test _ = not (appartient "programmation" trie_vide)
let%test _ = not (appartient "programmation" trie_presque_vide)
let%test _ = not (appartient "" trie_vide) 
let%test _ = appartient "" trie_presque_vide 
let%test _ = not (appartient "" trie_sujet)
let%test _ = not (appartient "lon" trie_sujet)
let%test _ = not (appartient "programmation" trie_sujet)
let%test _ = appartient "long" trie_sujet
let%test _ = appartient "la" trie_sujet
let%test _ = appartient "le" trie_sujet
let%test _ = appartient "bas" trie_sujet
let%test _ = appartient "de" trie_sujet
*)

(******************************************************************************)
(*   fonction d'ajout d'un élément dans un trie                               *)
(*   signature  : ajout : 'a -> ('a, 'b) trie -> ('a, 'b) trie = <fun>        *)
(*   paramètres : - un mot                                                    *)
(*                - un trie                                                   *)
(*   résultat   : le trie avec le mot ajouté                                  *)
(******************************************************************************)
let ajout mot (Trie(arbre, decompose, recompose)) =
  Trie (ajout_arbre (decompose mot) arbre,decompose,recompose)

(* On ne peut pas tester l'écgalité de deux fonctions *)
(* donc les tests ne porte que sur les arbres.        *)
  let%test _ =
  let Trie (a,_decomp,_recomp)= List.fold_right ajout
    ["bas"; "bat"; "de"; "la"; "lai"; "laid"; "lait"; "lard"; "le"; "les"; "long"]
    (nouveau decompose_chaine recompose_chaine)
in a = arbre_sujet

let%test _ =
  let Trie (a,_decomp,_recomp)= List.fold_right ajout
    ["basse"; "bat"; "de"; "la"; "lai"; "laid"; "lait"; "lard"; "le"; "les"; "long"]
    (nouveau decompose_chaine recompose_chaine)
in a <> arbre_sujet


(******************************************************************************)
(*   fonction de retrait d'un élément d'un trie                               *)
(*   signature  : trie_retrait : 'a -> ('a, 'b) trie -> ('a, 'b) trie = <fun> *)
(*   paramètres : - un mot                                                    *)
(*                - un trie                                                   *)
(*   résultat   : le trie, avec l'arbre non normalisé, avec le mot retiré     *)
(******************************************************************************)
let retrait mot  (Trie(arbre, decompose, recompose)) = 
    Trie(retrait_arbre ( decompose mot ) arbre ,decompose , recompose)


let%test _ = let Trie (a,_decomp,_recomp)= retrait "" trie_presque_vide in a = (Noeud(false,[]))
let%test _ = let Trie (a,_decomp,_recomp)= retrait "" trie_vide in a = (Noeud(false,[]))
let%test _ = let Trie (a,_decomp,_recomp)= retrait "prog" trie_sujet in a = arbre_sujet
let%test _ = let Trie (a,_decomp,_recomp)= retrait "" trie_sujet in a = arbre_sujet
let%test _ = let Trie (a,_decomp,_recomp)= retrait "lon" trie_sujet in a = arbre_sujet
let%test _ = not (appartient "bas" (retrait "bas" trie_sujet))
let%test _ = not (appartient "lai" (retrait "lai" trie_sujet))
let%test _ = (appartient "la" (retrait "lai" trie_sujet))
let%test _ = (appartient "laid" (retrait "lai" trie_sujet))
let%test _ = not (appartient "le" (retrait "le" trie_sujet))
let%test _ = not (appartient "long" (retrait "long" trie_sujet))


(******************************************************************************)
(*   fonction interne au Module qui génère la liste de tous les mots          *)
(*   d'un trie                                                                *)
(*   signature    : parcours : ('a, 'b) trie -> 'a list = <fun>              *)
(*   paramètre(s) : le trie                                                   *)
(*   résultat     : la liste des mots                                         *)
(******************************************************************************)
let parcours (Trie(arbre, decompose, recompose)) =
    let listes_caracteres = Arbre.parcours_arbre arbre in
    List.map recompose listes_caracteres


let%test _ = parcours trie_presque_vide = [""]
let%test _ = parcours trie_vide = []
let%test _ = eq_perm (parcours trie_sujet) ["bas"; "bat"; "de"; "la"; "lai"; "laid"; "lait"; "lard"; "le"; "les"; "long"]


(******************************************************************************)
(* procédure d'affichage d'un trie                                            *)
(*   signature  : affiche : ('a -> unit) -> ('a, 'b) trie -> unit = <fun>     *)
(*   paramètres : - une procédure d'affichage d'un mot                        *)
(*                - un trie                                                   *)
(*   résultat   : aucun                                                       *)
(******************************************************************************)
let affiche _ = failwith "TO DO affiche"

(*
let%expect_test _ = (affiche affiche_chaine trie_presque_vide);
[%expect{| |}]
let%expect_test _ = (affiche affiche_chaine trie_vide);
[%expect{||}]     
let%expect_test _ = (affiche affiche_chaine trie_sujet);
[%expect{|bas
bat
de
la
lai
laid
lait
lard
le
les
long
          |}]
*)