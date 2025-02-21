%{
  open Ast

  let make_fun (id : Var.t) (body : exp) (span : Span.t) : exp =
    aexp (efun id body) span
  
%}

%token <Span.t> FUN
%token <Span.t> ARROW 
%token <Span.t> LET
%token <Span.t> IN
%token <Span.t> EQ
%token <Span.t> PLUS
%token <Span.t> PRED
%token <Span.t> SWITCH
%token <Span.t> WITH
%token <Span.t> SUCC
%token <Span.t> BAR
%token <Span.t> ZERO
%token <Span.t> FOR
%token <Span.t> LPAREN
%token <Span.t> RPAREN
%token <Span.t * Var.t> ID
%token <Span.t * Int.t> NUM
%token EOF

%start prog
%type  <Ast.exp> prog


%%

expr:
    | appExpr    { $1 }
    | LET ID EQ expr IN expr { aexp (elet (snd $2) $4 $6) (Span.extend $1 $6.espan)}
    | FUN ID ARROW expr    { make_fun (snd $2) $4 (Span.extend $1 $4.espan) }
    | SWITCH expr WITH BAR ZERO ARROW expr BAR SUCC ID ARROW expr 
            { aexp (eswitch $2 $7 (snd $10) $12) (Span.extend $1 $12.espan)}
;

appExpr:
    | atomExpr { $1 }
    | appExpr atomExpr    { aexp (eapp $1 $2) (Span.extend $1.espan $2.espan) }
    | atomExpr PLUS atomExpr   { aexp (eadd $1 $3) (Span.extend $1.espan $3.espan)}
    | FOR atomExpr IN atomExpr { aexp (efor $2 $4) (Span.extend $1 $4.espan)}
    | PRED atomExpr   { aexp (epred $2) (Span.extend $1 $2.espan)}
;

atomExpr:
    | LPAREN expr RPAREN { $2 }
    | ID                { aexp (evar (snd $1)) (fst $1) }
    | NUM               { aexp (enat (snd $1)) (fst $1) }
;

prog:
    | expr EOF           { $1 }
;