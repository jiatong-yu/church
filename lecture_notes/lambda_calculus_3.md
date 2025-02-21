# Review:

e ::= x | lam x . e | e1 e2
e1 -> e2

## Main evaluation tool:
- beta:

—-----------------------------(beta)
(lam x e) e1 -> e [e1 / x]	

- app1:
e1 -> e1'
—-——————
e1 e2 -> e1' e2

- app2:
e2 -> e2'
—-——————
e1 e2 -> e1 e2'

- lambda:
e -> e'
————————
lam x e -> lam x e'

- Reflex:
e ->* e

- Transitivity:
e1 -> e2, e2 ->* e3   
————————— (trans)
e1 ->* e3

## Alpha equivalences:
Formal definition of alpha equivalence:
- e1 =a e2 // Syntactic equality modulo renaming of bound variables
   
        ————————————
           x = a x

- applications equal to applications:
        e1 =a e1, e2 =a e2'
        ————————————————————
        e1 e2 = a e1 e2'

- functions:
        e[z/x] =a e'[z/y] // (Z not in FV(e) U FV(e')) // aka Free variables
        ————————————————————————————
        lam x.e = a lam x . e'

Free variables:
- FV(x) = {x}
- FV(e1 e2) = FV(e1) U FV(e2)
- FV(lam x . e) = FV(e) \ {x} 
    "\" means set difference

## Beta equivalences:
Beta equivalence: e1 =b e2 // equivalence of terms that beta-reduce to a common term
    - e1 =b e2, there exists e3
        iff e1 ->* e3 and e2 ->* e3' and e3 =a e3'

    - Properties:
- if e1 =b e2, then e2 =b e1
- if e1 ->* e2, then e1 =b e2
    Follows from e2 always stepping to itself // by reflexivity

Can be useful for some proofs with "reverse evaluation"
Showing off power of lambda calculus:
e ::=  | lam x . e | e1 e2 | T | F | if e1 then e2 else e3 | (e1, e2) | π1 e | π2 e
Ω = (lam x . x x) (lam x . x x)
    - Non-terminating term
    - Never finishes

Y-combinator:
    - property that Y g =b g (Y g)

## Translations:
Question of "is lambda calculus powerful enough to encode powerful structures?"
- Church encodings showed that lambdas are equal in power to turing machines
- Now will show more rigorously how we might go about proving that
- Translation from these set of expressions to a subset of expressions 
    - Go about by defining a function
- trans : EXP -> EXP // meta level function
    - trans(x) = x
    - trans(lam x . e) = lam x . e' where e' = trans(e)
        - Alternate formulation: trans(lam x . e) = lam x . (trans(e))
        - Basically currying trans into e
    - trans(e1 e2) = trans(e1) trans(e2)
        - apply recursively translation onto each sub expression
        - Removes booleans etc from each sub expression
    - trans(T) = lam x . lam y . x
    - trans(F) = lam x . lam y . y
    - trans(if e1 then e2 else e3) = trans(e1) trans(e2) trans(e3)
        - Recall that  "if e1 then e2 else e3" is the same as "e1 e2 e3"
        - So, we apply trans to each sub expression

## Rules:
1. True: "if else"
  
———————————
if T then e1 else e2 -> e1


2. False: "if else"
  
———————————
if F then e1 else e2 -> e2


3. Workhorse of "if else"
e1 -> e'
——————————————————————
if e1 then e2 else e3 -> if e1' then e2 else e3 -> e1

## Theorem:
trans(if T then e1 else e2) =b trans(e1)

## Proof using equational reasoning:
trans(if T then e1 else e2) 
=b trans(T) trans(e1) trans(e2) // By definition of trans
=b (lam x . lam y . x) trans(e1) trans(e2) // By definition of trans
=b (lam y . trans(e1)) trans(e2) // By beta
=b trans(e1) // By beta


Q: How can we say it's beta equivalent?
A: We defined trans as such. Therefore, by definition, these are the same expression, thus =b

New data type: Pair
e ::=  | lam x . e | e1 e2 | T | F | if e1 then e2 else e3 | (e1, e2) | π1 e | π2 e
- π1 takes the first component of the pair

—--------------------------------
π1 (e1, e2) -> e1

- π2 takes the second component of the pair
   
—--------------------------------
π2 (e1, e2) -> e2

- trans((e1, e2)) = lam proj . proj trans(e1) trans(e2)
    = lam b . trans(if b then e1 else e2)
    // (trans(e))(lam x . lam y . x)

- trans(π1 (e1, e2)) = trans(e T):
    =b trans((e1, e2)) (lam x . lam y . x) // by def trans
    =b (lam proj . proj trans(e1) trans(e2)) (lam x . lam y . x) // by def trans
    =b (lam x . lam y . x) trans(e1) trans(e2) // by Beta
    =b trans(e1) // by Beta twice

- trans(π2 (e1, e2)) = trans(e F): 
    - Apply False function instead of True, same as above

- Y g =b g (Y g)
    - Should only take a couple lines
    - Hint for proof: if e1 -> e2, and you have an e2, you can say e2 = e1

## OCaml

- let x = e1 in e2 // no more OCaml
    - trans(let x = e1 in e2)
    - = (lam x . e2) e1

- Program:
    - let x = 3 in // x = 3
    - let f = lam y . y + x in // f adds 3
    - let g = lam x . f x in // g adds 3
    - g 7 // answer = 10

- Substitution:
    - let x = 3 in 
    - let g = lam x . ((lam y . y + x) x) in // g now doubles
    - g 7 // ans = 14
    - The variable "x" was captured!

Need to be careful about variable naming or defining substitutions
Use alpha conversion to create a new binder that doesn't have a clash

Define e [e' / x]:
    - x [e' / x] = e'
    - y [e' / x] = y
    - (e1 e2)[e' / x] = (e1 [e' / x] e2 [e' / x])
    - (lam x . e)[e' / x] = lam x . e               // s.t. x = x 
    - (lam y . e)[e' / x] = lam y . (e[e' / x])   // s.t. x != y, y not in FV(e')
    - (lam y . e)[e' / x]                                 //s.t. x != y, y in FV(e')
    // pick a z s.t. z != x, z not in FV(e), z not in FV(e')
    - = lam z . (e[z/y])[e'/x]
    // TLDR, we pick a new token not seen in either "alphabet"

## Assignment:
Assignment: Will be revolving around church encodings
We have a language called little lamb(da)
- lambda calc with extensions such as let, for, etc.
- Idea is to take your little lamb program and translate it into abstract syntax tree
- Lexer.ml -> Translate.ml -> Interp.ml -> Equality.ml 
AST = abstract syntax tree
Parser and lexer already implemented
Switch statement: ESwitch(e1, e2, x, e3)
- match e1 with
- | 0 -> e2
- | S(x) -> e3
- // S(x) is the successor with input x

Example: typeNat = 0 | S(Nat) // unbind one layer of Nat

Interp.ml produces a value
Interpreter simulates behavior of a program
Can turn rules into an ocaml program
Interpreter is already implemented. Use to check correctness of implementation
Two parts:
- Write a program to beta reduce internal language (lambda calc) expressions (and then check for equality)
- Write a program that translates little lam to the internal language using church encodings (which we know because lambda calculus is Turing complete)
Evaluation:
- Interpreting and translating should give same output as translating and then interpreting
- Note:
    - Beta-reduces are non-deterministic
    - Program is deterministic
    - Need to have some order of operations
    - E.g.
        - (lam x . lam y . x) (id) (Ω)
        - If you reduce Ω first, then we will never terminate
        - If we do (lam x . lam y . x) first, then we can terminate (and return id)
    - Rule: if a term terminates, it will terminate with Normal Order Evaluation (NOE)
    - Also, if given program doesn't terminate, you don't need to terminate either
    - Given Ω, then it's not going to terminate

e.e and span:
- e and exp are mutually exclusive
- Don't worry about span
Can use O-unit for easy unit testing
Can write test cases for natural numbers
failwith statements will compile but raise an exception

Q: Where will things be submitted? 
A: Turn in on Canvas. Submit translate.ml and equality.ml and proof

No autograder. Up to you to write test cases. You can share test cases in Slack.
