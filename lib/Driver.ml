open Interp
open Equality
open Translate
open Input
(* adapted from Prof. Kincaid's COS320 Assignments *)

let check f print =
  let (p,_) = parse f in
  if print then 
    print_endline("Parsed expression: " ^ Ast.ePretty p);
  let ve = eInterp p in
  if print then
    print_endline("V: " ^ Ast.ePretty ve);
  let vi1 = translate ve in
  if print then
    print_endline("I1: " ^ Ast.iPretty(vi1));
  let i = translate p in
  if print then
    print_endline("I: " ^ Ast.iPretty(i));
  let vi2 = iInterp i in
  if print then
    print_endline("I2: " ^ Ast.iPretty(vi2));
  betaEq vi1 vi2


