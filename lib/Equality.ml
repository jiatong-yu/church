(* 
Name:
NetID:

Name:
NetID:
*)

open Ast
open Var 
open Interp

module VarMap = Map.Make(Var)

(******************)
(* Alpha Equality *)
(******************)

(* alphaEqR implements equality assuming vars1 and vars2 are substitutions of
variables for variables in e1 and e2, respectively. *)
let rec alphaEqR (e1: iExp) (e2: iExp) 
  (vars1: Var.t VarMap.t) (vars2: Var.t VarMap.t): bool =
  match (e1, e2) with
  | IVar x, IVar y -> begin
    if x = y then true else
    match VarMap.find_opt x vars1, VarMap.find_opt y vars2 with
    | Some z1, Some z2 -> z1 = z2
    | None, None -> true
    | _,_ -> false 
  end
  | IFun (v1, b1), IFun(v2, b2) -> 
    let newVar = fresh "z" in (* this function creates a fresh variable *)
    let vars1' = VarMap.add v1 newVar vars1 in
    let vars2' = VarMap.add v2 newVar vars2 in
    alphaEqR b1 b2 vars1' vars2'
  | IApp (f1, v1), IApp (f2, v2) -> 
    (alphaEqR f1 f2 vars1 vars2) && (alphaEqR v1 v2 vars1 vars2)
  | _, _ -> false
  
(* alphaEq returns true if e1 and e2 are alpha equivalent and false otherwise *)
let alphaEq (e1: iExp) (e2: iExp) =
  alphaEqR e1 e2 VarMap.empty VarMap.empty

(*****************)
(* Beta Equality *)
(*****************)

(* betaReduce implements full beta reduction for e *)
let rec betaReduce (e: iExp) : iExp =failwith "unimplemented"
  

(* betaEq fully reduces e1 and e2 and tests for alpha equality of the results *)
let betaEq (e1: iExp) (e2: iExp) : bool = failwith "unimplemented"
  