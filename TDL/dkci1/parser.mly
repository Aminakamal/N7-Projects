/* Imports */
%{
open Type
open Ast.AstSyntax
%}

/* Tokens */
%token <int> ENTIER
%token <string> ID
%token <string> TID
%token RETURN
%token VIRG
%token PV
%token AO
%token AF
%token PF
%token PO
%token EQUAL
%token CONST
%token PRINT
%token IF
%token ELSE
%token WHILE
%token BOOL
%token INT
%token RAT
%token CO
%token CF
%token SLASH
%token NUM
%token DENOM
%token TRUE
%token FALSE
%token PLUS
%token MULT
%token INF
%token AND
%token NULL
%token NEW
%token VOID
%token REF
%token ENUM
%token EOF

/* Type de l'attribut synthétisé des non-terminaux */
%type <programme> prog
%type <enum_def> enum_def
%type <instruction list> bloc
%type <fonction> fonc
%type <instruction> i
%type <typ> typ
%type <typ * bool * string> param   
%type <expression> e 
%type <affectable> a

/* Type et définition de l'axiome */
%start <Ast.AstSyntax.programme> main

%%

main : le=enum_def* lf=fonc* ID li=bloc EOF  { Programme (le, lf, li) }

prog : lf=fonc* ID li=bloc  { Programme ([], lf, li) }

enum_def : ENUM n=TID AO lv=separated_list(VIRG, TID) AF PV
  { EnumDef (n, lv) }

fonc : t=typ n=ID PO lp=separated_list(VIRG, param) PF li=bloc 
  { Fonction(t, n, lp, li) }

param :
| t=typ n=ID              { (t, false, n) }
| REF t=typ n=ID          { (t, true, n) }

bloc : AO li=i* AF      { li }

i :
| t=typ n=ID EQUAL e1=e PV          { Declaration (t, n, e1) }
| a=a EQUAL e1=e PV                 { Affectation (a, e1) }
| CONST n=ID EQUAL e=ENTIER PV      { Constante (n, e) }
| PRINT e1=e PV                     { Affichage (e1) }
| IF exp=e li1=bloc ELSE li2=bloc   { Conditionnelle (exp, li1, li2) }
| WHILE exp=e li=bloc               { TantQue (exp, li) }
| RETURN exp=e PV                   { Retour (exp) }
| RETURN PV                         { RetourVide }
| n=ID PO lp=separated_list(VIRG, e) PF PV  { AppelProc (n, lp) }

typ :
| BOOL           { Bool }
| INT            { Int }
| RAT            { Rat }
| VOID           { Void }
| t=typ MULT     { Pointeur t }
| n=TID          { TypeEnum n }

a :
| n=ID                    { Ident n }
| PO MULT a=a PF          { Deref a }

e : 
| n=ID PO lp=separated_list(VIRG, e) PF   { AppelFonction (n, lp) }
| CO e1=e SLASH e2=e CF                   { Binaire(Fraction, e1, e2) }
| a=a                                     { Affectable a }
| TRUE                                    { Booleen true }
| FALSE                                   { Booleen false }
| e=ENTIER                                { Entier e }
| NUM e1=e                                { Unaire(Numerateur, e1) }
| DENOM e1=e                              { Unaire(Denominateur, e1) }
| PO e1=e PLUS e2=e PF                    { Binaire (Plus, e1, e2) }
| PO e1=e MULT e2=e PF                    { Binaire (Mult, e1, e2) }
| PO e1=e EQUAL e2=e PF                   { Binaire (Equ, e1, e2) }
| PO e1=e INF e2=e PF                     { Binaire (Inf, e1, e2) }
| PO exp=e PF                             { exp }
| NULL                                    { Null }
| PO NEW t=typ PF                         { New t }
| AND n=ID                                { Adresse n }
| REF n=ID                                { Ref n }
| v=TID                                   { ValeurEnum v }