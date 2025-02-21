type var = Var.t

type e = 
  | EVar of var
  | EFun of var * exp
  | EApp of exp * exp
  | ELet of var * exp * exp
  | ENat of int
  | EAdd of exp * exp
  | EPred of exp
  | ESwitch of exp * exp * var * exp
  | EFor of exp * exp 
and exp = 
  { e : e
  ; espan : Span.t
  }

(* for e f = \x. f (f ... (f x) ...) *)

(* internal representation using only lambda calculus *)
type iExp = 
  | IVar of var
  | IFun of var * iExp
  | IApp of iExp * iExp

let exp e : exp = {e = e; espan = Span.default}
let aexp e span : exp = { e = e.e; espan = span }
let evar x = exp (EVar x)
let eapp e1 e2 = exp (EApp (e1, e2))
let efun x e = exp (EFun(x, e))
let elet x e1 e2 = exp (ELet(x, e1, e2))
let eadd e1 e2 = exp (EAdd(e1, e2))
let epred e1 = exp (EPred e1)

let eswitch e1 e2 x e3 = exp (ESwitch (e1, e2, x, e3))
let enat n = if n >= 0 then exp(ENat(n)) else failwith "negative number"
let efor e1 e2 = exp (EFor (e1, e2))

let rec ePretty e : string =
  match e.e with
  | EVar x -> (Var.to_string x)
  | EApp (l, r) -> 
      Printf.sprintf "(%s) (%s)" (ePretty l) (ePretty r)
  | EFun (x, body) -> 
      Printf.sprintf "λ%s.(%s)" (Var.to_string x) (ePretty body)
  | ELet (x, e1, e2) -> 
      Printf.sprintf "let %s = %s in (%s)" (Var.name x) (ePretty e1) (ePretty e2)
  | ENat i -> (Int.to_string i)
  | EAdd (e1, e2) -> Printf.sprintf "(%s) + (%s)" (ePretty e1) (ePretty e2)
  | EPred e -> Printf.sprintf "pred (%s)" (ePretty e)
  | ESwitch (e1, e2, x, e3) -> 
    Printf.sprintf "switch %s with 0 -> %s | Succ(%s) -> %s" (ePretty e1) (ePretty e2) (Var.to_string x) (ePretty e3)
  | EFor (e1, e2) ->
    Printf.sprintf "for (%s) in (%s)" (ePretty e1) (ePretty e2)

let rec iPretty e : string = 
  match e with
  | IVar x -> (Var.to_string x)
  | IApp (l, r) -> Printf.sprintf "(%s) (%s)" (iPretty l) (iPretty r)
  | IFun (x, body) -> Printf.sprintf "λ%s.(%s)" (Var.to_string x) (iPretty body)