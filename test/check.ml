(* Run the check file using 
    dune build test
    dune exec test/check.exe *)

(* Edit these lines to change the program checked and whether the
intermediate translations/evaluations should be printed  *)
let file = "test/programs/simple1.txt"
let print_intermediates = true

(******************)

let _ = Driver.check file print_intermediates |> string_of_bool |> print_endline