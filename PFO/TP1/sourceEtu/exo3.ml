(*fonctions de type : int * int -> bool*)
let fct_1 (n, m) = n =m

(*fonctions de type : int -> bool*)
let fct_2 x = x > 0

(*fonctions de type : ‘a -> ‘a*)
let fct_3 x = -x

(*fonctions de type : ‘a * ‘a -> bool*)
let fct_4 (x, y) = (x, y) = (0, 0)

(*fonctions de type : ‘a * ‘b -> ‘a*)
let fct_5 (a, b) = a
