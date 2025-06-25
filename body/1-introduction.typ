#import "@preview/wordometer:0.1.4": word-count, total-words
#import "/utils.typ": todo, z3str3, z3-noodler, cite-wrong

= Introduction <introduction>

#let other-uses = (
  <saxenaSymbolicExecutionFramework2010>,
  <emmiDynamicTestInput2007>,
  <kiezunHAMPISolverString2009>,
  <senJalangiSelectiveRecordreplay2013>,
  <backesSemanticbasedAutomatedReasoning2018>,
  <wassermannSoundPreciseAnalysis2007>,
  <redelinghuysSymbolicExecutionPrograms2012>,
  <dantoniPowerSymbolicAutomata2017>,
)

Even though SAT is the archetypal NP-complete problem @karpReducibilityCombinatorialProblems1972, which in practice means no universally efficient solution exists, it is often necessary to find specific solutions in a reasonable amount of time. The SMT-LIB @barrett2010smt standard expands SAT to types such as integers, bitvectors and, the topic of this paper, strings. The Z3 solver @demouraZ3EfficientSMT2008, which implements this standard, helps us to find satisfiable assignments to queries such as two numbers $X$ and $Y$ where $X + Y < 13$ and $X dot Y > 10$. SMT solvers are widely used: just Amazon alone does one billion daily SMT queries to verify the correctness of their AWS user policies @rungtaBillionSMTQueries2022, and they are employed in many other areas too #cite-wrong(..other-uses).

As the use-cases become more complex and extensive, we naturally desire better performance. While optimizations and improvements may come from anywhere, one way to categorize them is between _general purpose_ and _domain-specific_. General purpose improvements usually come in the form of stronger implementations (such as #z3-noodler.display @chenZ3NoodlerAutomatabasedString2024 for Z3's strings). However, sometimes there is some exploitable property of a problem or a family of problems that you might want to take advantage of. Z3 provides the _tactics_ mechanism --- where the user can change some behavior of the solver or subdivide the problem --- ostensibly for this reason (even though domain-specific knowledge can also be manifested as additional "refining" constraints, and tactics do not _have_ to be domain-specific)

A question comes to mind when faced with these two approaches: *are there diminishing returns to using domain-specific guidance as the implementation strength increases?* That is, if an SMT implementation is particularly clever and efficient, it might be the case that guiding it is not very helpful, or even counterproductive. For instance, a human that tries to "guide" a strong chess engine will almost certainly make it perform worse, since chess engines are much better than humans. In a similar way, we explore to what extent guiding an SMT solver using domain-specific knowledge contributes more in overhead than in performance improvements.

== Contributions

In this paper we describe the relationship between solver implementation strength and the effectiveness of domain-specific guidance. The main contributions of the research are:

+ An automatic procedure to simulate domain-specific knowledge on arbitrarily large datasets while providing similar amounts of help, based on a quantified reduction the search space.
+ Insight on how the performance of Z3 changes when using domain-specific guidance.
+ Understanding on how the strength of an underlying implementation affects said change in performance when using domain-specific guidance.
+ A benchmarking suite to test and compare these models, providing 100% reproducible builds of the compared implementations using Nix.

A motivating use-case for the findings presented in this paper is, for example, helping a researcher working on formal verification to make an informed decision about whether it is more worthwhile to invest time on understanding a problem versus in running or improving a solver.

