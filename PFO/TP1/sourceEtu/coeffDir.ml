(*
   coeffDir : float -> float -> float -> float ->float
   Retourne le coefficient directeur de la droite passant par  deux points
   Parametre x1 y1 x2 y2 : float, float, float, float les coordonnees des deux points
   Resultat : float, coefficient directeur
   Précondition : les deux points doivent etre differentes
*)
let coeffDir x1 y1 x2 y2 =
  if x1 = x2 
  then  failwith "Meme abssice"
  else (y1 - y1)/(x1 -x1)


