open Ast
open Var

(*******************)
(* Church Encoding *)
(*******************)



(* translate e converts external syntax into internal syntax, eliminating all 
numeric computations and replacing them with the appropriate church encoding *)
let rec translate (e: exp) : iExp = 
  match e.e with
  | EVar x -> IVar x
  | EFun (x, e1) -> IFun (x, translate e1)
  | EApp (e1, e2) -> IApp (translate e1, translate e2)
  | ELet (x, e1, e2) -> failwith "unimplemented"
    
  | ENat n -> failwith "unimplemented"
    
  | EAdd (n, m) -> failwith "unimplemented"
    
  | EPred n -> failwith "unimplemented"
    
  | ESwitch (e1, e2, v, e3) -> failwith "unimplemented"
    
  | EFor (e1, f) -> failwith "unimplemented"
    
