(* 
  Run the test suite using 
    dune build test
    dune exec test/test.exe

  We encourage you to add more of your own tests to ensure your code is working
  (this test suite requires you have a working implementation of alphaEq)
*)

open OUnit2
open Ast
open Translate
open Equality

let v str = Var.fresh str

let x = v "x"
let id_applied =
  let y = v "y" in
  IApp(IFun(y, IVar y), IVar x)

let beta_tests =
  "test suite for beta equivalence" >::: [
    "apply identity function" >:: (fun _ -> assert_equal true (betaEq (id_applied) (IVar (x))));
  ]

let zero_ans = 
  let f1 = v "f1" in
  let f2 = v "f2" in
  IFun (f1, (IFun (f2, (IVar f2))))
let translate_tests =
  "test suite for translate" >::: [
    "zero" >:: (fun _ -> let translation = translate(enat 0) in
        assert_equal true (alphaEq (translation) zero_ans));
  ] 


let _ = print_endline "runing tests" 
  ; run_test_tt_main beta_tests
  ; run_test_tt_main translate_tests

