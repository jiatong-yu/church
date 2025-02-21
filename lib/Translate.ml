open Ast
open Var

(*******************)
(* Church Encoding *)
(*******************)



(* translate e converts external syntax into internal syntax, eliminating all 
numeric computations and replacing them with the appropriate church encoding *)
(* Helper functions for Church encoding *)

(* church numeral: 0 -> \s.\z. z, n -> \s.\z. s (s ... (s z)) *)
let rec church n =
  if n = 0 then IVar "z" else IApp(IVar "s", church (n-1))

(* Church booleans *)
let true_term = IFun("t", IFun("f", IVar "t"))
let false_term = IFun("t", IFun("f", IVar "f"))

(* Church addition: ADD = \n.\m.\s.\z. n s (m s z) *)
let add_term =
  IFun("n", IFun("m", IFun("s", IFun("z",
    IApp( IApp(IVar "n", IVar "s"), IApp( IApp(IVar "m", IVar "s"), IVar "z") ) )
  ))))

(* Church predecessor: PRED = \n.\s.\z. n (\g.\h. h (g s)) (\u. z) (\u. u) *)
let pred_term =
  IFun("n", IFun("s", IFun("z", 
    IApp(
      IApp(
        IApp(IVar "n",
            IFun("g", IFun("h", IApp(IVar "h", IApp(IVar "g", IVar "s"))))
        ),
        IFun("u", IVar "z")
      ),
      IFun("u", IVar "u")
    )
  )))

(* iszero: ISZERO = \n. n (\x. false) true *)
let iszero = IFun("n", IApp( IApp(IVar "n", IFun("x", false_term)), true_term))

(* translate function: translates external syntax into internal syntax with Church encodings *)
let rec translate (e: exp) : iExp = 
  match e.e with
  | EVar x -> IVar x
  | EFun (x, e1) -> IFun (x, translate e1)
  | EApp (e1, e2) -> IApp (translate e1, translate e2)
  | ELet (x, e1, e2) -> IApp (IFun (x, translate e2), translate e1)
  | ENat n -> IFun("s", IFun("z", church n))
  | EAdd (e1, e2) -> IApp (IApp (add_term, translate e1), translate e2)
  | EPred e1 -> IApp (pred_term, translate e1)
  | ESwitch (e1, e2, x, e3) ->
      (* switch e1 with 0 -> e2 | succ x -> e3
         translates to: if e1 is zero then translate e2, else translate (eSubst x (EPred e1) e3) *)
      IApp(
        IFun("n", IApp(
          IApp(IVar "n", IFun("x", translate e2)),
          translate (eSubst x (EPred e1) e3)
        )),
        translate e1
      )
  | EFor (e1, e2) ->
      (* for e1 in e2 translates to a function that applies e2, e1 times to its argument *)
      IFun("x", IApp( IApp(translate e1, translate e2), IVar "x"))
 
  
    
