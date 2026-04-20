open Rat
open Compilateur
open Exceptions

exception ErreurNonDetectee

(****************************************)
(** Chemin d'accès aux fichiers de test *)
(****************************************)

let pathFichiersRat = "../../../../../tests/type/avec_fonction/fichiersRat/"

(**********)
(*  TESTS *)
(**********)


let%test_unit "test2"= 
  let _ = compiler (pathFichiersRat^"test2.rat") in ()

let%test_unit "testAppel1"= 
  let _ = compiler (pathFichiersRat^"testAppel1.rat") in ()

let%test_unit "testAppel2"= 
  let _ = compiler (pathFichiersRat^"testAppel2.rat") in ()

let%test_unit "testAppel3"= 
  let _ = compiler (pathFichiersRat^"testAppel3.rat") in ()

let%test_unit "testAppel4"= 
  let _ = compiler (pathFichiersRat^"testAppel4.rat") in ()

let%test_unit "testAppel5"= 
  let _ = compiler (pathFichiersRat^"testAppel5.rat") in ()

let%test_unit "testAppel6"= 
  try 
    let _ = compiler (pathFichiersRat^"testAppel6.rat")
    in raise ErreurNonDetectee
  with
  | TypesParametresInattendus _ -> ()

let%test_unit "testAppel7"= 
  try 
    let _ = compiler (pathFichiersRat^"testAppel7.rat")
    in raise ErreurNonDetectee
  with
  | TypesParametresInattendus _ -> ()

let%test_unit "testAppel8"= 
  try 
    let _ = compiler (pathFichiersRat^"testAppel8.rat")
    in raise ErreurNonDetectee
  with
  | TypesParametresInattendus _ -> ()

let%test_unit "testAppel9"= 
  try 
    let _ = compiler (pathFichiersRat^"testAppel9.rat")
    in raise ErreurNonDetectee
  with
  | TypesParametresInattendus _ -> ()

let%test_unit "testAppel10"= 
  try 
    let _ = compiler (pathFichiersRat^"testAppel10.rat")
    in raise ErreurNonDetectee
  with
  | TypesParametresInattendus _  -> ()

let%test_unit "testAppel11"= 
  try 
    let _ = compiler (pathFichiersRat^"testAppel11.rat")
    in raise ErreurNonDetectee
  with
  | TypesParametresInattendus _  -> ()

let%test_unit "testAppel12"= 
  try 
    let _ = compiler (pathFichiersRat^"testAppel12.rat")
    in raise ErreurNonDetectee
  with
  | TypeInattendu(Int,Bool) -> ()

let%test_unit "testAppel13"= 
  try 
    let _ = compiler (pathFichiersRat^"testAppel13.rat")
    in raise ErreurNonDetectee
  with
  | TypeInattendu(Int,Rat) -> ()

let%test_unit "testRetourFonction1"= 
  let _ = compiler (pathFichiersRat^"testRetourFonction1.rat") in ()

let%test_unit "testRetourFonction2"= 
  try 
    let _ = compiler (pathFichiersRat^"testRetourFonction2.rat")
    in raise ErreurNonDetectee
  with
  | TypeInattendu(Bool,Int) -> ()

let%test_unit "testRetourFonction3"=
  let _ = compiler (pathFichiersRat^"testRetourFonction3.rat") in ()

let%test_unit "testRetourFonction4"=
  try
    let _ = compiler (pathFichiersRat^"testRetourFonction4.rat")
    in raise ErreurNonDetectee
  with
  | TypeInattendu(Bool,Int) -> ()

let%test_unit "testRecursiviteFonction"= 
  let _ = compiler (pathFichiersRat^"testRecursiviteFonction.rat") in ()

let%test_unit "test"= 
  let _ = compiler (pathFichiersRat^"test.rat") in ()

let%test_unit "code_factrec" = 
let _ = compiler   (pathFichiersRat^"factrec.rat") in ()

(* Tests des affectables*)

let%test_unit "testAffectableRetourFonction" = 
  let _ = compiler (pathFichiersRat^"testAffectableRetourFonction.rat") in ()

(*Tests des pointeurs*)

let%test_unit "testPointeurRetour" = 
  let _ = compiler (pathFichiersRat^"testPointeurRetour.rat") in ()

let%test_unit "testPointeurNullCompatible" = 
  let _ = compiler (pathFichiersRat^"testPointeurNullCompatible.rat") in ()

(* Tests des Procédures *)

let%test_unit "testProcedureType" = 
  let _ = compiler (pathFichiersRat^"testProcedureType.rat") in ()
  
(* TESTS : Passage par référence    *)

let%test_unit "testRefTypeOK" = 
  let _ = compiler (pathFichiersRat^"testRefTypeOK.rat") in ()

let%test_unit "testRefManquant" = 
  try 
    let _ = compiler (pathFichiersRat^"testRefManquant.rat")
    in raise ErreurNonDetectee
  with
  | ParametreRefIncorrect _ -> ()

let%test_unit "testRefEnTrop" = 
  try 
    let _ = compiler (pathFichiersRat^"testRefEnTrop.rat")
    in raise ErreurNonDetectee
  with
  | ParametreRefIncorrect _ -> ()

let%test_unit "testRefMauvaisePosition" = 
  try 
    let _ = compiler (pathFichiersRat^"testRefMauvaisePosition.rat")
    in raise ErreurNonDetectee
  with
  | ParametreRefIncorrect _ -> ()

let%test_unit "testRefTypeIncompatible" = 
  try 
    let _ = compiler (pathFichiersRat^"testRefTypeIncompatible.rat")
    in raise ErreurNonDetectee
  with
  | TypesParametresInattendus _ -> ()

let%test_unit "testRefProcedure" = 
  let _ = compiler (pathFichiersRat^"testRefProcedure.rat") in ()

let%test_unit "testRefRetour" = 
  let _ = compiler (pathFichiersRat^"testRefRetour.rat") in ()

let%test_unit "testRefPointeur" = 
  let _ = compiler (pathFichiersRat^"testRefPointeur.rat") in ()  

(* Fichiers de tests de la génération de code -> doivent passer la TDS *)
open Unix
open Filename

let rec test d p_tam = 
  try 
    let file = readdir d in
    if (check_suffix file ".rat") 
    then
    (
     try
       let _ = compiler  (p_tam^file) in (); 
     with e -> print_string (p_tam^file); print_newline(); raise e;
    )
    else ();
    test d p_tam
  with End_of_file -> ()

let%test_unit "all_tam" =
  let p_tam = "../../../../../tests/tam/avec_fonction/fichiersRat/" in
  let d = opendir p_tam in
  test d p_tam
