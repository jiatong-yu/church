# Lambda Calculus
The following is a lambda expression: e = x | λx.e | e1 e2.
The meta-variable  is either a variable (x), function (λx.e), or function application (e1 e2).

It’s convention to “left-align” function applications. 
For example, the expression:
(λx.λy.x)a b
is evaluated as:
(((λx.λy.x) a) b)


If we take one evaluative step, we would substitute a for x in (λx.λy.x).
This would leave us with (λy.a)b. We then replace all occurrences of y with b, which leaves us with just a.  

## Reduction Semantics
The general pattern for function applications follows e1 e2 -> e2.

Beta reduction:
-------------------(β)
 (λx.e) e1 -> e[e1/x]
    - (λx.e) e1 is a beta-redex
    - e[e1/x] can be  read as "substitute e1 for x in e"

Application rules:

    e1 -> e1'
-------------------(app1)
    e1 e2 -> e1' e2

    e2 -> e2'
-------------------(app2)
    e1 e2 -> e1 e2'

    e -> e'
-------------------(lam)
    λx.e -> λx.e'


Reflexive-transitive closure of

-------------------(reflex)
    e ->* e

    e1 -> e2
    e2 ->* e3
-------------------(trans)
    e1 ->* e3


## Alpha Equivalence
Consider the identity functions λx.x and λz.z.
Then, λx.x = λz.z. We say that λx.x and λz.z are "alpha-equivalent" because they are the same up to the consistent renaming of bound variables.
Thus, λf.λx.f x = λg.λy.g y = λx.λf.x f.

In the expression (λx.z x), x is a bound variable. z is a free variable. You can imagine that z is defined in another file. You can change bound variables and still have alpha equivalency.

Lambda Calculus is **Turing Complete**.

Example -redex:
Take ((λx.x) (λw.w)) ((λz.z) (λy.y)).
We can take multiple paths in this reduction. 

            ((λx.x) (λw.w)) ((λz.z) (λy.y))
                    /				\
            apply (app1, β)			apply (app2, β)
                  /					   \
		((λw.w))((λz.z)(λy.y))     ((λx.x)(λw.w))(λy.y)
		    	/					      \
        apply (app2, β)					apply (app1, β)
	         /					             \
    (λw.w)(λy.y)				 	        (λw.w)(λy.y)
          /							           \
apply (β)						             apply (β)
      /							                  \
	(λy.y)                                      (λy.y)				

**Confluence**
Notice that the different reduction paths resolved into the same expression (λy.y). This is a property known as **confluence**. More formally,
If e1 -> e2 and e1 -> e3 then there exists some e4 such that e2 ->* e4 and e3 ->* e4.
					
                             e1
				          /       \
                        e2       e3
				        *\        /*
						     e4