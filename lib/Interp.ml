(* 
Name:
NetID:

Name:
NetID:
*)

open Ast
open Var

(* A substitution based interpreter for external syntax *)

exception UnboundVariable of string

(* substitutes v with e1 in e2 *)
let rec eSubst v e1 e2 =
  match e2.e with
  | EVar x -> 
    if Var.equals v x then e1 else (evar x)
  | EFun (x, body) -> 
    if Var.equals x v then e2 else (efun x (eSubst v e1 body))
  | EApp (e3, e4) -> (eapp (eSubst v e1 e3 ) (eSubst v e1 e4))
  | ELet (x, e3, e4) -> if Var.equals x v then
    (elet x (eSubst v e1 e3) e4) else
    (elet x (eSubst v e1 e3) (eSubst v e1 e4))
  | ENat _ -> e2
  | EAdd (e3, e4) -> (eadd (eSubst v e1 e3) (eSubst v e1 e4))
  | EPred e3 -> (epred (eSubst v e1 e3))
  | _ -> failwith "unimplemented"

let rec eInterp (e : exp) : exp =
  match e.e with
  | EVar x -> raise (UnboundVariable (name x))
  | EFun (x, body) -> (efun x body)
  | EApp (e1, e2) -> (
      let v1 = eInterp e1 in
      let v2 = eInterp e2 in
      match v1.e with
      | EFun (var, body) -> let newe = eSubst var v2 body in
          eInterp newe
      | _ -> failwith "bad function application" )
  | ELet (x, e1, e2) -> 
    let v1 = eInterp e1 in
    eInterp (eSubst x v1 e2)
  | ENat _ -> e
  | EAdd (e1, e2) -> begin
    let v1, v2 = eInterp e1, eInterp e2 in
    match (v1.e, v2.e) with
      | (ENat a, ENat b) -> (enat (a + b))
      | _,_ -> failwith "ill formed add"
  end
  | EPred e1 -> begin
    let v1 = eInterp e1 in
    match v1.e with
      | ENat a -> 
        if a = 0 then (enat 0) else (enat(a-1))
      | _ -> failwith "ill formed pred"
    end
  | ESwitch (e, e1, x, e2) -> begin
    let v = eInterp e in
    match v.e with
    | ENat 0 -> eInterp e1
    | ENat n -> 
      eInterp (eSubst x (enat (n-1)) e2)
    | _ -> failwith "ill formed switch"
  end
  | EFor (e1, e2) -> begin
    let v1, v2 = eInterp e1, eInterp e2 in
    match v1.e, v2.e with
      | ENat a, EFun (_,_) -> 
        let var = fresh "var" in
        let rec makeFor num f curr: exp =
          if num = 0 then curr
          else makeFor (num-1) f (eapp f curr)
        in
        let body = makeFor a v2 (evar var) in
        efun var body
      | _, _ -> failwith "ill formed for"
    end

(* A substitution based interpreter for the internal syntax *)

let rec iSubst v e1 e2 =
  match e2 with
  | IVar v1 -> if Var.equals v1 v then e1 else e2
  | IFun (x, body) -> if Var.equals x v then e2 else IFun(x, iSubst v e1 body)
  | IApp (e3, e4) -> IApp(iSubst v e1 e3, iSubst v e1 e4)

let rec iInterp (e: iExp) =
  match e with
  | IVar v1 -> raise (UnboundVariable (name v1))
  | IFun (_, _) -> e
  | IApp (f, g) -> begin
    match iInterp f with
    | IFun (var, body) -> iInterp (iSubst var g body)
    | _ -> failwith "bad application"
  end