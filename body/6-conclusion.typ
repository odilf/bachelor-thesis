#import "/utils.typ": todo, z3str3, z3-noodler

= Conclusions <conclusion>

Answering the titular question: yes, there do seem to be diminishing returns for domain specific guidance as the implementation strength increases, at least in the case of #z3-noodler.display as compared to #z3str3.display. A simple "restrict the search space" approach has inconsistent results: it does speed up some cases, but it slows down others. Small, fast cases are slowed more often than not by additional constraints. As the problems get more complex, the average speedup tends to increase. And, while for #z3str3.display there is a point where there are consistent significant speedups, for #z3-noodler.display almost all ranges on average are slowed down.

In other words, #z3-noodler.display demonstrates that reducing the search space, although arguably being conventional wisdom and a sound strategy for simple constraint propagation, is not necessarily helpful. Extrapolating this point, we can take away that, even in the simpler cases, one needs to have deep knowledge of how the solver works to be confident that domain-specific help actually improves performance.

We obtained these results using a procedure, introduced in this paper, to quantify the help given by constraints on strings, and how to apply them given a solution. This way we were able to benchmark the performance of #z3str3.display and #z3-noodler.display with and without help on thousands of cases. The implementations were packaged using Nix to aid in reproducibility, and we provide a Rust tool to run the benchmarks. We strove to make it relatively easy to modify, in order to help future researchers doing a similar investigations.

== Limitations and future work

In this regard, there are many potential developments for the presented research, of which we highlight the most important ones in the rest of this section.

Firstly, one clear limitation was time needed to run larger scale tests. However, at a fundamental level, since equivalent problems take a lot longer to run with #z3str3.display than #z3-noodler.display, to compare problems that take a long time for #z3-noodler.display means that they will take a _very_ long time for #z3str3.display, so it is hard to avoid this pitfall.

Another limitation is the lack of possibility to communicate "soft constraints" to the solver; that is, constraints that the solver is free to use or not use. If this mechanism were implemented then solvers might be smart enough to ignore the constraints if they would add too much overhead, and we would hope to see less slowdowns overall, especially for #z3-noodler.display. This should likely be prototyped in standalone solvers, since it is a big ask to put it on the SMT-LIB standard, but it has potential to be useful.

 Of course, one could carry the same experiments with different SMT theories and solver implementations. Depending on what theories and solvers are used, our implementation can be reused to different extents. For instance, comparing two Z3 implementations for a different theory can be done by just changing the way additional bounds are generated (which is fairly easy) and packaging the different implementations. One particularly interesting project for potential future benchmarking is #smallcaps[Z3alpha] @luLayeredStagedMonte2024, which finds good tactics using Monte Carlo methods, so it would be interesting to see how it compares to tailor-made tactics for specific problems. However, that would require a fundamentally different methodology from the one shown in this paper.

Finally, as explained in @automatic-simulation-of-domain-specific-knowledge, the _unsat_ case is theoretically tougher than the _sat_ case; but the hope is that, in practice, most cases of _unsat_ problems are relatively simple and there should be a procedure somewhat similar to @algorithm-domain-specific-constraints (but probably not identical) that provides meaningful results. It might even be worthwhile to apply the exact same approach blindly to see what happens, but finding the theoretical justification would be best.
