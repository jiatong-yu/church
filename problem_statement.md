# Project Overview 
This repository is for Assignment 2 of COS510 (Programming Languages) taught in Princeton University. In this assignment, we will study the untyped lambda calculus, a Turing-complete programming language with just three constructs -- variables, functions, and function application.  The syntax of expressions in the lambda calculus are defined as follows.

e ::= x |\x.e | e1 e2

The lambda calculus has just a single kind of value, the function (\x.e)  and yet it is capable of encoding any of the data structures we see in conventional programming languages (integers, booleans, records, ML-style datatypes, objects, etc.).

The key learning goals for this assignment are:

To gain a deeper understanding of the lambda calculus, including operational semantics, equivalence of lambda terms,  and church encodings.
To gain experience working with the implementation of a simple programming language in OCaml.

## Setup
- You will need to download OCaml for this assignment.
- We have some EXTREMELY USEFUL lecture notes stored in "./lecture_notes/"
    - Make sure to read through them
    - They cover all the material we have covered in the first 3 weeks of class
    - They also provide a brief explanation of the assignment

## Provided Files
In the lib folder:
    - Ast.ml - contains definitions of our “external” and “internal” syntax, as well as helper functions. The “external” syntax, Little Lamb , is capable of representing programs that use functions, integers, and a variety of simple operations on integers. The “internal” syntax represents the untyped lambda calculus, i.e., it only contains variables, functions, and function application. The file also contains the functions ePretty and iPretty, which output exp and iExp expressions as strings (which will be helpful for debugging).
    - Interp.ml - contains the eSubst and eInterp functions, which implement an interpreter for Little Lamb, and the iSubst and iInterp functions, which implement an interpreter for the internal syntax
    - Driver.ml - contains the code to "check" your translation (more details below). 
    - Equality.ml - contains an alpha equivalence function and will contain your beta reduction and equivalence functions
    - Translate.ml - will contain your translation between the external and internal syntaxes
    - Console.ml, Input.ml, Span.ml, Var.ml, Lexer.mll, Parser.mly - files which contain utilities for reading in a file and turning it into an exp. There’s no need to understand these files deeply, but feel free to look at them if you are curious about the compilation process!
In the test folder:
    - test.ml - contains a sample unit test and is where you will write additional unit tests
    - check.ml - runs the check() function from the driver.ml file. You can change the file name read from to check different programs.

# Background
## Free Variables and Substitution

The set of free variables in a lambda calculus expression FV(e) is defined as follows.

FV(x)     = {x}
FV(\x.e)  = FV(e) - {x}
FV(e1 e2) = FV(e1) U FV(e2)

Let e0<e/x> be the substitution of e for variable x in e0.  It is defined as follows. 

x<e/x>        = e
y<e/x>        = y                    (y  x)
(e1 e2)<e/x>  = (e1<e/x>) (e2<e/x>)
(\x.e1)<e/x>  = \x.e1                
(\y.e1)<e/x>  = \y.(e1<e/x>)         (y  x and y ∉ FV(e))
(\y.e1)<e/x>  = \z.(e1<z/y><e/x>)    (y  x and for any z such that:
 							   z  x and
                                      z ∉ FV(e1) and 
   z ∉ FV(e))

Lemma 1 (Totality of Substitution):  For all expressions e0 and e, and variables x, there exists e' such that e0<e/x> = e'.

The proof is by induction on the structure of e0.  (Not required but a useful exercise.)

## Alpha Equivalence

Two terms are alpha-equivalent if they vary only in the names of their bound variables. You can think of this as “syntactic equality for the lambda calculus”:  terms are equivalent if they look equivalent (modulo renaming of bound variables).  We typically write e1 = e2 if e1 and e2 are alpha equivalent.  

Alpha-equivalence is defined as follows (where FV(e) is the set of free variables in an expression e).

-------- (a-var)
x = x

e1 = e1'        e2 = e2'
---------------------------------(a-app)
e1 e2 = e1' e2'

e[z/x] = e'[z/y]        z  FV(e) U FV(e')
--------------------------------------------------- (a-lam)
\x.e = \y.e'

Lemma 2 (Reflexivity of Alpha-Equivalence): 
For all e, e = e.
Lemma 3 (Transitivity of Alpha-Equivalence): 
For all e1, e2, e3, if e1 = e2 and e2 = e3 then e1 = e3.
Lemma 4 (Symmetry of Alpha-Equivalence): 
For all e1, e2, if e1 = e2 then e2 = e1.

The proofs are not required but you can do them as an exercise. 

In the file equality.ml, alpha equality is implemented by the alphaEq function (iExp -> iExp -> bool). Read over this function and make sure you understand how it works.


# Part 1: Beta Equivalence & Normal Order Reduction
Definition (Beta-equivalence e1 = e2):  Let e -->* e' be full beta reduction, as defined below.  We say that two expressions e1 and e2 are beta-equivalent, written e1 = e2,  iff there exists e1' and e2' such that e1 -->* e1' and e2 -->* e2' and  e1' = e2'.

Single Step Full Beta Reduction 


e1 --> e1’
–––––––––––––--- (app1)
e1 e2 --> e1’ e2


e2 --> e2’
–––––––––––––--- (app2)
e1 e2 --> e1 e2’


e --> e’
–––––––––––––------------------ (lambda)
\lambda x.e --> \lambda x . e’


–––––––––––––----------------- (beta)
(\lambda x .e) e1 --> e [e1/x]


Multi-step Full Beta Reduction


---------- (reflex)
e -->* e


e1 -> e2      e2 -->* e3
----------------------------- (trans)
e1 ->* e3

Lemma 5 (Reflexivity of Beta-Equivalence): 
For all e1,e2, if e1 = e2 then  e1 = e2.
Lemma 6 (Transitivity of Beta-Equivalence): 
For all e1, e2, e3, if e1 = e2 and e2 = e3 then e1 = e3.
Lemma 7 (Symmetry of Beta-Equivalence): 
For all e1, e2, if e1 = e2 then e2 = e1.
Lemma 8 (Congruence Properties of Beta-Equivalence -- aka "substitution of equals for equals"): 
For all e1, e2, e1', e2', 
if e1 = e1' and e2 = e2' then e1 e2 = e1' e2'
if e1 = e1' then \x.e1 = \x.e1'

Full beta reduction is non-deterministic --  an expression may contain many different beta-redexes (an expression of the form (\x.e1) e2) and there is a choice of which beta redux to evaluate next.  Some evaluation strategies can lead to non-termination when others lead to termination  For instance let Ω be a non-terminating lambda term such as ((\x.x x) (\x. x x)) , which reduces to itself in one step. Consider:

(\x.\y.y) Ω

If we  repeatedly evaluate the argument, we make no progress --- (\x.\y.y) Ω reduces to itself in one step.   If instead we substitute Ω for x, we are left with just the identity function \y.y  and have terminated  with no further beta redexes to apply.

Fortunately, there is an evaluation order that leads to strong properties.  Quoting colleagues at Cornell (italics are mine):

Under the normal order reduction strategy, the leftmost-outermost redex is always the next to be reduced. By leftmost-outermost, we mean that if e1 and e2 are redexes in a term and e1 is a subterm of e2, then e1 will not be reduced next; and among those redexes that are not subterms of other redexes, which are all pairwise incomparable with respect to the subterm relation, the leftmost one is chosen for reduction. It is known that if a term has a normal form at all, then normal order reduction will converge to it. 

In the file equality.ml, write a function betaReduce : iExp -> iExp that implements normal order reduction for lambda calculus terms. You should replace failwith “unimplemented” with your beta reduction function.

Note that betaReduce will not terminate on some arguments (eg betaReduce (Ω) will not terminate) -- that's ok!  Your betaReduce  function should terminate whenever normal order reduction finds a normal form.

Write a second function betaEq : iExp -> iExp -> bool that implements beta equivalence by using betaReduce to fully reduce each argument and then tests for alpha equality of the resultant terms. Again, replace failwith “unimplemented” with your beta equality function.  Again, your implementation of betaEq need not terminate if normal order reduction on either of the terms being compared does not terminate.

# Part IIA: Implementing Church Encodings

In our external syntax “exp” (also called Little Lamb), we have a variety of common language constructs, such as natural numbers, addition, and switch expressions. As we learned in class, lambda calculus is a Turing-complete language, meaning we can translate all of these constructs into lambda terms. 

Additionally, we demonstrated that it was possible to encode Boolean values true and false and various operations on them in the pure lambda calculus.  In this exercise we will consider encoding natural numbers. One way to do that is to encode zero as (\s.\z.z) and then encode any positive number n as \s.\z. s (s (s (... (s z) ...))) where there are n applications of the function s.  For example, 2 is \s.\z. s (s z). 

Your job is to implement a function translate : exp -> iExp in the file Translate.ml. (Search for failwith "unimplemented" and replace it with your code to obtain a working application.)  This function should translate an expression from our external syntax into an expression in our internal syntax. We recommend first looking at the eInterp function to make sure you understand the semantics (i.e., behavior) of each of the constructs. Below, we will also give you a short explanation of the constructs in the external syntax that are not present in the internal syntax. 

let x = e1 in e2 : substitutes e1 for the variable x  in the expression e2
e1 + e2 : adds the expressions e1 and e2. The church encoding should take two functions that represent numbers and apply the “s” function e1 + e2 times.  (If e1 and e2 do not represent numbers, the encoding may do arbitrary things -- do not worry about this case or other "ill-typed" situations.)
pred e : calculates the predecessor value of e (equal to e - 1). In other words, the church encoding should be a function that takes a function representing a number and applies the “s” function 1 fewer times. 
switch e1 with 0 -> e2 | succ n -> e3 : if e1 = 0, then e2, otherwise substitute n with e1-1 in e3. This is analogous to a match statement in ocaml. 
for e1 in e2 : Should generate a function f that takes an argument x and applies the function e2 to x  e1 times.

Example:

let inc = \n.\s.\z.s (n s z)

It should be the case that:

trans(for 3 inc) = \x.inc(inc(inc(x)))

It also should be the case that:

trans((for 3 inc) 2) = trans(5) 

Note:  You may want to do Part IIC below before doing your implementation, to prove that your translation has (some of) the appropriate correctness properties.

# Part IIB: Testing Your Church Encodings
Simple Unit Tests:  To test your church encodings, we have provided a couple of files in the test folder (as described above). We recommend first using test.ml on small cases (translating 0, 1 + 1, etc) where you know the output. To do this, add your test cases to test.ml following the format of the example “zero” case. To run your tests, run the following:

dune build test
dune exec test/test.exe

This will run all tests and return which tests failed.

Commutativity Tests:  A more extensive (and fun!) test uses check.ml to test that evaluation and translation commute.  "Commuting properties" are a useful and common kind of theorem that ensures two functions are defined in a consistent manner.  More specifically if trans is your translation function and evaluate is an evaluation function, the following theorem expresses the relationship more formally: 

Theorem (Evaluation Commutes with Translation):  
for any expression e,  
trans (evaluate (e)) == evaluate (trans (e)). 

The following picture presents the situation diagrammatically (another common way of presenting such theorems):

 e ----evaluate---------------> v
 |                              |
trans                         trans
 |                              |
\/                             \/
 i -----evaluate-------> i1 == i2

You won't be proving this property, but you will be testing for this property (testing connotes checking something about some values over which a universal quantifier ranges).  Indeed, check.ml will check this property for any program you write. We recommend using check.ml to check larger expressions to ensure you’re handling variable shadowing, multiple function applications, and other tricky cases properly.

To do this, create a file with the code you wish to test (written in the external syntax) and change the file string in check.ml to be your file’s name. There is an example program in the /programs folder. To run the file, run the following:

dune build test
dune exec test/check.exe

When the print_intermediates flag is set to false, the program will just print if i1 and i2 are equivalent. If it is set to true, it will print the values of v, i, i1 and i2 as well as if i1 and i2 are equivalent. Please message Theresa on slack if you have questions about the testing suite.