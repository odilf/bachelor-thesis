#import "/utils.typ": todo, url-link, z3str3, z3-noodler
#import "/assets/workflow-diagram.typ": workflow-diagram

= Methodology <methodology>

The main goal of the presented research is to compare the difference in performance for various Z3 string solver implementations. To do that we need to run an experiment, for which we need:
1. A dataset of SMT2 problems about strings to benchmark the performance of each solver.
2. Domain-specific knowledge for each problem, or a simulation thereof.
3. A program to carry out the benchmarks in a reproducible way.

To start, in terms of datasets, we do not have to look any further than the SMT-LIB dataset for strings, which provides over 100k varied test cases for strings. Specifically, we use `QF_S`, `QF_SLIA` and `QF_SNIA`, non-incremental 2024 edition @preinerSMTLIBRelease20242024b (`QF` indicates quantifier-free; `S`, strings; and `LIA` and `NIA`, linear/non-linear integer arithmetic, respectively).

The "creation" of domain-specific knowledge and the runner implementation are more complicated and thus constitute the rest of this section.

== Automatic simulation of domain-specific knowledge <automatic-simulation-of-domain-specific-knowledge>

Domain-specific knowledge should help the solver find a solution faster. One could study a few problems in detail to find some specific optimization, but it very quickly becomes intractable at the scales needed to have a chance of being representative of what happens "in general".

Thus, we present an automatic procedure to simulate domain-specific knowledge. At a high level, it works by taking the solution (which can be obtained by running the solver normally) and using it to give "hints" to the solver. The "hints" are, concretely, six types of constraints we can add to a variable, given a solution. The additional constrains help a typical constraint propagator since they cut off earlier decisions that are ultimately infeasible.

However, the constraint types are fundamentally different so we need to quantify how much help each constraint gives. We do this by calculating the log increase of the probability of guessing the solution given said constraint. Then, we can choose a value for help and add constraints until we reach the desired value.

The resulting procedure (shown in @algorithm-domain-specific-constraints, at the end of the section) gives sensible results. E.g., if we take the string "hello world" and constrain it to end with "rld" then we expect the help to be somewhere around $3 / 11 approx 27.2%$ (since we revealed 3/11 characters), and indeed the help comes out to $26.7%$ #footnote[The full 27.2% help would be given if we already knew the length, but this constraint only reveals that the length is greater or equal to 3, therefore the actual help is smaller since length is still unknown.]. The rest of this section explains the motivation behind this approach and its implementation in more detail.

=== Constraints and quantifying help

There are many constraints for strings but, generally, given a solution for a variable $X$ there are six straightforward, standalone types of constraints one might add, listed in @table-constraint-candidates (for concise referencing later, we give each constraint a symbol to represent them).

#figure(
  table(
    align: center,
    inset: (x: 5pt, y: 4pt),
    columns: (auto, auto, auto, auto),
    [*Constraint name*], [*Symbol*], [*Equation*], [*Parameter*],
    [Length greater than], $>=$, $|X| >= ell$, [$ell$ where $ell <= |s|$],
    [Length less than], $<$, $|X| < ell$, [$ell$ where $ell > |s|$],
    [Length equals], $=$, $|X| = |s|$, [None],
    [Prefix of (i.e., starts with)],
    $tack.r$,
    $X = partial s plus.double Y$,
    $|partial s|$,

    [Suffix of (i.e., ends with)],
    $tack.l$,
    $X = Y plus.double partial s$,
    $|partial s|$,

    [Substring (i.e., contains)],
    $tack.t$,
    $X = Y plus.double partial s plus.double Z$,
    $|partial s|$,
  ),
  caption: [Constraints that can be added to a standalone variable $X$ given \ a solution $s$, a substring of the solution $partial s$ and fresh variables $Y$ and $Z$],
  placement: top,
) <table-constraint-candidates>

However, applying these constraints can be tricky. One could choose a random valid value for either a substring of $s$, $partial s$, or a length $ell$, and add the constraints as given, but the help that each constraint provides is very different. For example, the prefix, suffix, and substring constraints imply a "length greater than" constraint since if a variable has to contain a substring $partial s$ then the length has to be at least $|partial s|$, that is, $|X| > |partial s|$.

We can solve this by quantifying how much each constraint "reduces the search space" and adjusting the parameters accordingly. Since the search space is infinite, we consider a guesser that chooses a length from an exponential distribution $"Exp"(lambda)$ and then chooses a random substring of that length, which has $C$ possibilities for each character. The help that a constraint gives is a measure of the reduction of the expected number of guesses when using said constraint or, equivalently, the *increase in probability of guessing correctly*. Specifically, we define the help $h^*$ given by a constraint with symbol $*$ to be:

$ h^* = -(ln(p^*) - ln(p)) / (ln(p)) $

Where $p$ is the probability of guessing the solution without help and $p^*$ with help.

This scheme is the simplest metric that gives meaningful results for all the listed constraints. The help calculation is done in log space because it maps multiplications in probability calculations to additive changes in help (otherwise revealing a single character to the solver would correspond to 99.9995% help just by itself).

The derivation for the help used by each constraint is not too complicated, but wordy, so it is available in full in @appendix-derivations. In @table-constraint-parameters-help we show the results.

#let table = {
  set math.equation(numbering: none)
  table(
    columns: (auto, 1fr, auto),
    inset: (x: 4pt, y: 3pt),
    align: center + horizon,
    [*Constraint*], [*Help, given parameters*], [*Parameters, given help*],
    [Length greater than],
    $ h^>= = (lambda ell) / ln(p_s) $,
    $ ell = (h^>= ln(p_s)) / lambda $,

    [Length less than],
    $ h^< = ln(1 - e^(-lambda ell)) / ln(p_s) $,
    $ ell &= ln(1 - e^(h^<) p_s) / (-lambda) $,

    [Length equals], $ ln(p_ell) / ln(p_s) $, $ "None" $,
    [Prefix (starts with)],
    $ h^(tack.r) = |partial s| (ln(C) + lambda) / (-ln(p_s)) $,
    $ |partial s| &= h^(tack.r) (-ln(p_s)) / (ln(C) + lambda) $,

    [Suffix (ends with)],
    $ h^(tack.l) = |partial s| (ln(C) + lambda) / (-ln(p_s)) $,
    $ |partial s| &= h^(tack.l) (-ln(p_s)) / (ln(C) + lambda) $,

    [Substring (contains)],
    $
      h^(tack.t) = (|partial s| ln(C) - ln(|s| - |partial s| + 1)) / (-ln(p_s))
    $,
    [Transcendental eq., \ find by binary search],
  )
}

#figure(
  table,
  caption: [Relationships between constraint parameters and help they provide, \ given the probability of guessing the string $p_s$ and of guessing the length $p_ell$.],
  placement: top,
) <table-constraint-parameters-help>

#[
  One might expect at first that $lambda$ and $C$ would cancel out, but this is not the case. In particular, when $lambda$ is larger, the guesses are generally lower, so a "length greater than" constraint is more informative than if $lambda$ was small (see @fig-less-than-constraint-lambda-comparison). Similarly, for $C$, the more possible characters there are, the more informative each character you reveal is.
]
#figure(
  image("/assets/plots/less-than-constraint-lambda-comparison.svg"),
  caption: [Probability density of $"Exp"(lambda)$ constraint with a smaller (blue) vs bigger (orange) value of $lambda$. Shaded area indicates the search space removed by a "greater than" constraint],
  placement: top,
) <fig-less-than-constraint-lambda-comparison>

=== Applying constraints given a solution

We now need to apply the constraints. To do that, we first need concrete values for $C$ and $lambda$. We can calculate the value of $C$ easily according to the SMT-LIB specification of strings @SMTLIBSatisfiabilityModulo, which results in $C = 3 dot 16^4 = 196 space.quarter 608$. As for $lambda$, the choice is more arbitrary, but a sensible option is to choose the value that maximizes finding the solution, since the help is relative to that. The value turns out to be $lambda = ln((|s| + 1) / (|s|))$ (per @appendix-max-lambda). This value should provide a representative enough range of lengths the solver is considering, and it definitely provides a representative range of lengths for the specific solution we are hinting at.

The final piece to the puzzle is considering that lengths are discrete, so the constraints cannot give arbitrary help (e.g., if a solution is 3 characters long, you can only give a 1, 2 or 3 character prefix/suffix). We handle this by undershooting the help and adding different constraints until the actual help is at a very small distance $epsilon$ to the target (in our case, $epsilon = 0.01$) or until we run out of unique constraints (repeated constraints make each other redundant and thus misrepresent the help calculation). This is done in Lines @line-while-ge-epsilon[], @line-undershoot-help[], @line-continue-if-h-gt-r[] and @line-subtract-h-r[] of @algorithm-domain-specific-constraints.


#import "@preview/lovelace:0.3.0": *

#figure(
  caption: [Generation of domain-specific constraints.],
  supplement: "Algorithm",
  kind: "pseudocode",
)[
  #pseudocode-list(hooks: 4pt)[
    + Given help $h$ and $n$ variables with solutions strings $s_1, s_2, ..., s_n$:
      + #line-label(<line-random-variable-split>) Split $h$ into $n$ uniformly distributed ranges ($h_1, h_2, ..., h_n$).
      + *For each* $n$:
        + Let $r = h_n$ (help given so far)
        + *While* $r > epsilon$ #line-label(<line-while-ge-epsilon>)
          + Let $c$ be a random non-visited constraint (if none exist, *break*). #line-label(<line-random-constraint>)
          + Let $lambda = ln((|s_n|) / (|s_n| + 1))$
          + Calculate constraint parameter $p$ of $c$ (either $ell$ or $|partial s|$) according to @table-constraint-parameters-help.
          + Calculate help $h'$ given by $floor(p)$ according to @table-constraint-parameters-help (undershoot help) #line-label(<line-undershoot-help>)
          + *If* $h' > r$, *continue* #line-label(<line-continue-if-h-gt-r>)
          + Add constraint $c$ with parameter $floor(p)$
          + Subtract $h'$ from $r$ #line-label(<line-subtract-h-r>)
  ]
] <algorithm-domain-specific-constraints>

As explained in @sat-vs-unsat, the _unsat_ case is different enough from the _sat_ case that we left it outside the scope of this paper. In terms of giving help, we can see the difference in the sense that it is trivial to give 100% help in the _sat_ case (just give the solution), while for the _unsat_ case you would need some kind of "for all" proof. This case needs to be handled with additional care, so we leave it as possible future work.

== Benchmark runner and reproducibility <runner-and-reproducibility>

We have written a tool, in Rust, that can run all the benchmarks automatically and store them in an SQLite3 database. As illustrated in @fig-workflow, the runner first collects the problems into the databasem then, it computes their solutions and whether they are _sat_ and, finally, we generate the tactics according to @algorithm-domain-specific-constraints for each implementation to be benchmarked on every problem with different levels of help (in our case $0$ and $0.9$), multiple times (as many as time budget allows, in our case between 3 to 5). We only benchmark on problems that both #z3str3.display and #z3-noodler.display were able to find _sat_ solutions for, to prevent unfairness.

#figure(
  workflow-diagram(),
  caption: [Experiment's pipeline diagram. Gray text indicates example data.],
  placement: top,
) <fig-workflow>

We have taken care to achieve the highest standard of reproducibility. Namely, to generate random numbers for @line-random-variable-split and @line-random-constraint of @algorithm-domain-specific-constraints we used the #url-link("https://crates.io/crates/wyrand")[`wyrand` crate], which is a deterministic and portable RNG; which we seed with a hash of the problem's content. We also provide #url-link("https://nixos.org")[Nix] derivations that are deterministic and allow for any user to trivially run the programs since, in practice, it is often a hassle to compile and integrate alternative implementations. All in all, any person can easily do the same exact experiments given the source code, which is available on #url-link("https://github.com/odilf/smt-guidance-experiments")[GitHub] and an #url-link("https://git.odilf.com/odilf/smt-guidance-experiments")[independent forge].


The results were ran on a M1 Max CPU with 8GB of RAM. To ensure consistency, apart from running each case multiple times, the laptop was plugged in with no other user programs running.
