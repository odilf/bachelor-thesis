#import "/utils.typ": todo, url-link
#let tc = todo[cite]

= Methodology <methodology>

The main goal of the research today is to compare the difference in performance for various Z3 string solver implementations. To do that we need to run an experiment, for which we need:
1. A dataset of SMT2 problems about strings to benchmark the performance of each solver.
2. Domain-specific knowledge for each problem, or a simulation thereof.
3. A runner to carry out the benchmarks in a reproducible way.

To start, in terms of datasets, we don't have to look any further than the SMT-LIB dataset for strings, which provides over a hunder thousand varied test cases. Specifically, we use `QF_S`, `QF_SLIA` and `QF_SNIA` #tc.

The "creation" of domain-specific knowledge and the runner implementation are more complicated, and is what the rest of this section is about.

== Benchmarking dataset: automatic simulation of domain-specific knowledge #todo[A bit long, would be nice to make it fit in one line.] <automatic-simulation-of-domain-specific-knowledge>
// == Dataset & automatic simulation of domain-specific knowledge <automatic-simulation-of-domain-specific-knowledge>

Domain-specific knowledge /* or DSK for short #todo[is this necessary? I do like it...]*/ should help the solver find a solution faster. One could study a few problems in detail to find some specific optimization, but it very quickly becomes intractable at the scales needed to have a chance of being representative of what happens "in general". Thus, the implementation used in this paper works by taking the solution (which can be obtained by running any SMT solver normally) and using it to give "hints" to the solver. #todo[Should I clarify why this is not general?].

Specifically, Z3 can provide a satisfying assignment for each variable for any given problem, or an unsatisfiability core if the problem is unsolvable.

When a problem is satisfiable (i.e., _sat_), Z3 can provide a model solution, that gives satisfiable representations for each variable. We take the model and add constraints based on the answer. There are many ways to do this. The most straightfowrard is to add constraints on each variable of either starting with, containing, or ending with the solution of the variable. The

The exact procedure goes as follows:

#import "@preview/lovelace:0.3.0": *

#figure(caption: [Tactic generation algorithm], supplement: "Listing")[
#todo[Improve the algorithm]
  #pseudocode-list(hooks: 0.25em)[
    + *Define* generate tactics for $n$ variables:
      + #line-label(<random-simplex-split>) Split the help into $n$ (i.e., n-simplex sampling).
      + *For each* $n$: 
        + #line-label(<random-constraint>) Choose a constraint $c$ randomly between
          + #smallcaps[StartsWith] $=>$ Select the first $h_n$ fraction of the characters.
          + #smallcaps[Contains]
          + #smallcaps[EndsWith].
        + Take a portion $#raw("help")_n$ of the characters and add it to $c$.
  ]
] <tactic-generation-procedure>

While an analogous procedure might be usable in the _unsat_ cases, there were enough complications for this to be left outside the scope of the current paper. Further discussion about the challenges and potential solutions is given at @future-unsat-cores.

== Runner and reproducibility <runner-and-reproducibility>

We've written a tool, in Rust, that can run all the benchmarks automatically and store them in an SQLite3 database.

Care has been taken to achieve the highest standard of reproducibility. To generate random numbers for @random-simplex-split and @random-constraint @tactic-generation-procedure, the #url-link("https://crates.io/crates/wyrand")[`wyrand` crate] is used, which is a fast, deterministic and portable RNG; which we seed with a hash of the problem's content. We also provide #url-link("https://nixos.org")[Nix] derivations that are deterministic and allow for any user to trivially run the programs since, in practice, it is often a hassle to compile and integrate alternative implementations. All in all, any person can easily do the same exact experiments given the source code, which is available on #url-link("https://github.com/odilf/smt-guidance-experiments")[GitHub], TU Delft's GitLab #todo[Get access?] and an #url-link("https://git.odilf.com/odilf/smt-guidance-experiments")[independent forge].

Finally, to ensure the integrity of the results, the benchmarks were run on a single, standalone server, with no other services running, in the same physical conditions, multiple times.
