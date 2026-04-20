{

  open TokenJava
(*  open String *)
(*  open Str *)
  exception LexicalError

}

(* Macro-definitions *)
let minuscule = ['a'-'z']
let majuscule = ['A'-'Z']
let chiffre = ['0'-'9']
let alphabet = minuscule | majuscule
let alphanum = alphabet | chiffre | '_'
let commentaireBloc = (* A COMPLETER *) "/*" _* "*/" 
let commentaireLigne = "//" [^'\n']* '\n'
let nonzerodigit = ['1'-'9']
let digitAndUnderscores = (chiffre | '_')+
let underscores = '_'+
let digits = chiffre|  chiffre digitAndUnderscores? chiffre
let hexDigit = ['0'-'9'] | ['a' - 'f'] | ['A' - 'F']
let hexDigitAndUnderscore = (hexDigit|'_')+ (hexDigit|'_')*
let octalDigit = ['0'-'7']
let OctalDigitsAndUnderscores = (octalDigit|'_')+ (octalDigit|'_')*
let octalDigits = octalDigit | (octalDigit  OctalDigitsAndUnderscores+ octalDigit)
let binaryDigitsAndUnderscores = (['0'-'1']|'_')+ (['0'-'1']|'_')*
let binaryDigits = ['0'-'1']|(['0'-'1'] binaryDigitsAndUnderscores ['0'-'1'])
(* Analyseur lexical : expression reguliere { action CaML } *)
rule lexer = parse
(* Espace, tabulation, passage a ligne, etc : consommes par l'analyse lexicale *)
  | ['\n' '\t' ' ']+    { lexer lexbuf }
(* Commentaires consommes par l'analyse lexicale *)
  | commentaireBloc  	{ lexer lexbuf }
  | commentaireLigne	{ lexer lexbuf }
(* Structures de blocs *)
  | "("                 { PAROUV }
  | ")"                 { PARFER }
  | "["                 { CROOUV }
  | "]"                 { CROFER }
  | "{"                 { ACCOUV }
  | "}"                 { ACCFER }
(* Separateurs *)
  | ","                 { VIRG }
  | ";"                 { PTVIRG }
(* Operateurs booleens *)
  | "||"                { OPOU }
  | "&&"                { OPET }
  | "!"                 { OPNON }
(* Operateurs comparaisons *)
  | "=="                { OPEG }
  | "!="                { OPNONEG }
  | "<="                { OPSUPEG }
  | "<"                 { OPSUP }
  | ">="                { OPINFEG }
  | ">"                 { OPINF }
(* Operateurs arithmetiques *)['1'-'9']
  | "+"                 { OPPLUS }
  | "-"                 { OPMOINS }
  | "*"                 { OPMULT }
  | "/"                 { OPDIV }
  | "%"                 { OPMOD }
  | "."                 { OPPT }
  | "="                 { ASSIGN }
  | "new"               { NOUVEAU }
(* Mots cles : types *)
  | "bool"              { BOOL }
  | "char"              { CHAR }
  | "float"             { FLOAT }
  | "int"               { INT }
  | "String"            { STRING }
  | "void"              { VOID }
(* Mots cles : instructions *)
  | "while"		{ TANTQUE }
  | "if"		{ SI }
  | "else"		{ SINON }
  | "return"		{ RETOUR }
(* Mots cles : constantes *)
  | "true"		{ (BOOLEEN true) }
  | "false"		{ (BOOLEEN false) }
  | "null"		{ VIDE }
(* Nombres entiers : A COMPLETER *)
  | ('0' | (['1' - '9'] chiffre*)) as texte   { (ENTIER (int_of_string texte)) }
  | ('0' | (nonzerodigit '[' digits ']') | (nonzerodigit underscores digits)) as texte  { (ENTIER (int_of_string texte)) }
  | (('0' & 'x' & (hexDigit|(hexDigit hexDigitAndUnderscore? hexDigit)))|('0' & 'X' & (hexDigit|(hexDigit hexDigitAndUnderscore? hexDigit)))) as texte   { (ENTIER (int_of_string texte)) }
  |(('0' &  octalDigits )| ('0' & underscores octalDigits) ) as texte   { (ENTIER (int_of_string texte)) }
  | (('0' & 'b' & binaryDigits) | ('0' & 'B' & binaryDigits)) as texte   { (ENTIER (int_of_string texte)) }

(* Nombres flottants : A COMPLETER *)
  | (chiffre+ "." chiffre+) as texte     { (FLOTTANT (float_of_string texte)) }
(* Caracteres : A COMPLETER *)
  | "'" _ "'" as texte                   { CARACTERE texte.[1] }
(* Chaines de caracteres : A COMPLETER *)
  | '"' _* '"' as texte                  { CHAINE texte }
(* Identificateurs *)
  | majuscule alphanum* as texte              { TYPEIDENT texte }
  | minuscule alphanum* as texte              { IDENT texte }
  | eof                                       { FIN }
  | _                                         { raise LexicalError }

{

}
