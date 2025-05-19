#import "/utils.typ": todo

= Conclusion and future work <conclusion>

// == Isn't it clearly better to improve the general case? #todo[This shouldn't be a heading.]

We have seen so and so #todo[Fill this in.].

#todo[Introduce this better]
We would like to take a moment to discuss a meta-question. An argument can be made that improving just a single problem using domain-specific knowledge is clearly worse. If you make the general purpose solver better, even if by a miniscule amount, it is going to be multiplied by all the uses of the solver which will quickly give you much more improvements than you could ever hope for a single optimization. 

This is not entirely false, but it overlooks two points. Firstly, there are certain problems that can't feasibly complete in time, and better general-purpose computation doesn't solve this; but secondly and more importantly, from the perspective of the specific problem, improving the solver in general is the "specific" optimization and understanding the problem better is the "general" and more sought after improvement.

#todo[Tie it up with a bow nicely]

// == Future recommendations
== Using unsat cores <future-unsat-cores>

As mentioned in @automatic-simulation-of-domain-specific-knowledge, the _unsat_ cases where not tested in this paper. At a first glance, it seems one could use a similar approach to the _sat_ case and see what happens, but there are practical challenges and the results might not be significant. 

 The main problem is that the _unsat_ case is fundamentally different from the _sat_ case. Finding _sat_ is NP-complete, finding _unsat_ is undecidable. The helpfulness of the _unsat core_ given by Z3 has no guarantees (e.g., just returning the original problem is perfectly valid!), and --- even though you can --- it is not appropriate to use the same logic as with the _sat_ case because the motivation doesn't used there doesn't necessarily hold here.

However, in practice, most cases of _unsat_ problems are relatively simple and there should be a procedure somewhat similar to @tactic-generation-procedure (but not identical) that provides meaningful results.

#todo[Write end]
