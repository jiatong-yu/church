# Introduction to Untyped Lambda Calculus
## Why?
Lambda Calculus is at the heart of nearly every single programming language we have today!
Just as powerful as C++, Java, Python, etc despite being extremely small and elegant
Invented before there were computers

## Syntax and Conventions:
	x, y, z for variables of the lambda calculus
	
	e::= x | λx.e | e1e2
		read λx.e as a function with argument x and body e (defn of 
             function)
		read e1e2 as function e1 with argument e2 (function 
application)

	λx.x					identity (from now on id)
	λx.λy.x				function that returns first arg
 	λx.λy.y				function that returns 2nd arg
	
	λx.x y	-> 	λx.(x y) 		our convention right extension
	λx.x y z   ->   λx.((x y) z)	our convention left-associative

		Similar to how we would evaluate 2 * 3 + 7 with parsing 
           rules.

## Executing Lambda Expressions
1. (λf.λx.fx) id 
   -> λx.id x

	The ‘id’ is the argument to the first λf due to parenthesis

2. (λf.λf.f x) id
   -> λf.f x

The ‘f’ in ‘f x’ refers to the most recent enclosure ‘f’
Inner λf shadows the outer λf

3. λx.λy.(λy.y x z) y
   -> λx.λy.(y x z) y

‘z’ is a free variable (not bound by an enclosure)
‘Y’ is a bound variable (bound by an enclosure)
‘λy’ is a binding site for y

4. ((λx.λy.x y) (λz.y))
-> continued next lecture? DUN DUN DUN
