#import "/utils.typ": todo, z3str3, z3-noodler

= Conclusion and future work <conclusion>

Answering our titular question: yes, there do seem to be diminishing returns for domain specific guidance as the implementation strength increases, at least in the case of #z3-noodler.display as compared to #z3str3.display. A simple "restrict the search space" approach has inconsistent results: it does speed up some cases, but it slows down others. Small, fast cases are slowed more often than not by additional constraints. As the problems get more complex, the average speedup tends to increase. And, while for #z3str3.display there is a point where there are consistent significant speedups, for #z3-noodler.display most ranges barely exceed a speedup of 1 (i.e., neither a speedup nor a slowdown).

#z3-noodler.display demonstrates that reducing the search space, although arguably being conventional wisdom, is not necessarily helpful.

Another point we can take away is that, even in the simpler cases, one needs to have deep knowledge of how the solver works to be confident that domain-specific help actually improves performance.

To obtain our results, in this paper we also introduced a procedure to quantify the help given by constraints on strings, and how to apply them given a solution. This way we were able to benchmark the performance of #z3str3.display and #z3-noodler.display with and without help on over ten thousand cases. The implementations were packaged using Nix to aid in reproducibility, and we provide a Rust tool to run the benchmarks. We strived to make it relatively easy to modify, in order to help future researchers doing a similar investigations.

== Future recommendations

In this regard, there are various possible expansions for the presented research. One clear limitation was time needed to run larger scale tests. It is hard to compare 

 Of course, one could carry the same experiments with different SMT theories and solver implementations. Depending on what theories and solvers are used, our implementation can be reused to different extents. For instance, comparing two Z3 implementations for a different theory can be done by just changing the way additional bounds are generated (which is fairly easy) and packaging the different implementations. #todo[Add specific examples of LIA, bitvectors, real numbers, etc].

 One particularly interesting project for potential future benchmarking is #smallcaps[Z3alpha] @luLayeredStagedMonte2024, which finds good tactics using Monte Carlo methods, so it would be interesting to see how it compares to tailor-made tactics for specific problems. However, that would require a fundamentally different methodology from the one shown in this paper.

As explained in @automatic-simulation-of-domain-specific-knowledge, the _unsat_ case is tougher theoretically than the _sat_ case; but the hope is that, in practice, most cases of _unsat_ problems are relatively simple and there should be a procedure somewhat similar to @algorithm-domain-specific-constraints (but probably not identical) that provides meaningful results. It might even be worthwhile to apply the exact same approach blindly to see what happens, but finding the theoretical justification would be best.

#todo[You can expand the constraint to add cross-variables constraints.]

#todo[Tie it up with a bow nicely (i.e., find a nice short and sweet final paragraph)]

