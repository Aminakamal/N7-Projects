open Rat
open Compilateur

(* Changer le chemin d'accès du jar. *)
let runtamcmde = "java -jar ../../../../../tests/runtam.jar"
(* let runtamcmde = "java -jar /mnt/n7fs/.../tools/runtam/runtam.jar" *)

(* Execute the TAM code obtained from the rat file and return the ouptut of this code *)
let runtamcode cmde ratfile =
  let tamcode = compiler ratfile in
  let (tamfile, chan) = Filename.open_temp_file "test" ".tam" in
  output_string chan tamcode;
  close_out chan;
  let ic = Unix.open_process_in (cmde ^ " " ^ tamfile) in
  let printed = input_line ic in
  close_in ic;
  Sys.remove tamfile;    (* à commenter si on veut étudier le code TAM. *)
  String.trim printed

(* Compile and run ratfile, then print its output *)
let runtam ratfile =
  print_string (runtamcode runtamcmde ratfile)

(****************************************)
(** Chemin d'accès aux fichiers de test *)
(****************************************)

let pathFichiersRat = "../../../../../tests/tam/avec_fonction/fichiersRat/"

(**********)
(*  TESTS *)
(**********)


(* requires ppx_expect in jbuild, and `opam install ppx_expect` *)
let%expect_test "testfun1" =
  runtam (pathFichiersRat^"testfun1.rat");
  [%expect{| 1 |}]

let%expect_test "testfun2" =
  runtam (pathFichiersRat^"testfun2.rat");
  [%expect{| 7 |}]

let%expect_test "testfun3" =
  runtam (pathFichiersRat^"testfun3.rat");
  [%expect{| 10 |}]

let%expect_test "testfun4" =
  runtam (pathFichiersRat^"testfun4.rat");
  [%expect{| 10 |}]

let%expect_test "testfun5" =
  runtam (pathFichiersRat^"testfun5.rat");
  [%expect{| |}]

let%expect_test "testfun6" =
  runtam (pathFichiersRat^"testfun6.rat");
  [%expect{|truetrue|}]

let%expect_test "testfuns" =
  runtam (pathFichiersRat^"testfuns.rat");
  [%expect{| 28 |}]

let%expect_test "factrec" =
  runtam (pathFichiersRat^"factrec.rat");
  [%expect{| 120 |}]

(* Tests des affectables *)
let%expect_test "testAffectableFonction" =
  runtam (pathFichiersRat^"testAffectableFonction.rat");
  [%expect{| 10 |}]
  
(* Tests des pointeurs *)
let%expect_test "testPointeurFonction" =
  runtam (pathFichiersRat^"testPointeurFonction.rat");
  [%expect{| 99 |}]

let%expect_test "testPointeurIncrement" =
  runtam (pathFichiersRat^"testPointeurIncrement.rat");
  [%expect{| 66 |}]
  
(* Tests des procédures *)  

let%expect_test "testProcedureExecution" =
  runtam (pathFichiersRat^"testProcedureExecution.rat");
  [%expect{| 6 |}]

let%expect_test "testPointeurSwap2" =
  runtam (pathFichiersRat^"testPointeurSwap.rat");
  [%expect{| 105 |}]
  
(* TESTS Phase 3 : Passage par référence    *)

let%expect_test "testRefSimple" =
  runtam (pathFichiersRat^"testRefSimple.rat");
  [%expect{| 41 |}]

let%expect_test "testRefRatModif" =
  runtam (pathFichiersRat^"testRefRatModif.rat");
  [%expect{| 1[1/2] |}]

let%expect_test "testRefSwap" =
  runtam (pathFichiersRat^"testRefSwap.rat");
  [%expect{| 105 |}]

let%expect_test "testRefMixte" =
  runtam (pathFichiersRat^"testRefMixte.rat");
  [%expect{| 936 |}]

let%expect_test "testRefRecursif" =
  runtam (pathFichiersRat^"testRefRecursif.rat");
  [%expect{| 5 |}]

let%expect_test "testRefChaine" =
  runtam (pathFichiersRat^"testRefChaine.rat");
  [%expect{| 5556565758 |}]

let%expect_test "testRefTriple" =
  runtam (pathFichiersRat^"testRefTriple.rat");
  [%expect{| 246 |}]

let%expect_test "testRefRatComplet" =
  runtam (pathFichiersRat^"testRefRatComplet.rat");
  [%expect{| 5[5/4][3/4] |}]

let%expect_test "testRefPointeurInit" =
  runtam (pathFichiersRat^"testRefPointeurInit.rat");
  [%expect{| 42 |}]

let%expect_test "testRefProcedure" =
  runtam (pathFichiersRat^"testRefProcedure.rat");
  [%expect{| 10[5/6] |}]
  
let%expect_test "testRefRatComplet2" =
  runtam (pathFichiersRat^"testRefRatComplet2.rat");
  [%expect{| 3[3/4][1/4] |}]
  
let%expect_test "testEnumExecution" =
  runtam (pathFichiersRat^"testEnumExecution.rat");
  [%expect{| truefalse |}]

let%expect_test "testEnumBoucle" =
  runtam (pathFichiersRat^"testEnumBoucle.rat");
  [%expect{| 5 |}]

let%expect_test "testEnumCombinaison" =
  runtam (pathFichiersRat^"testEnumCombinaison.rat");
  [%expect{| 1550 |}]

  

