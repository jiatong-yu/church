type var = Var.t

type e = private
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

type iExp = 
  | IVar of var
  | IFun of var * iExp
  | IApp of iExp * iExp

val exp: e -> exp
val aexp : exp -> Span.t -> exp
val evar : var -> exp
val eapp : exp -> exp -> exp
val efun : var -> exp -> exp
val elet : var -> exp -> exp -> exp
val eadd : exp -> exp -> exp
val epred : exp -> exp
val enat : int -> exp
val eswitch : exp -> exp -> var -> exp -> exp
val efor : exp -> exp -> exp

val ePretty : exp -> string
val iPretty : iExp -> string