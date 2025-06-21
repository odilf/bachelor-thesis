#import "@preview/wordometer:0.1.4": word-count, total-words
#import "/utils.typ": todo, z3str3, z3-noodler
#let tc = todo[cite]

= Introduction <introduction>

#let other-uses-citation = {
  let labels = (
    <saxenaSymbolicExecutionFramework2010>,
    <emmiDynamicTestInput2007>,
    <kiezunHAMPISolverString2009>,
    <senJalangiSelectiveRecordreplay2013>,
    <backesSemanticbasedAutomatedReasoning2018>,
    <wassermannSoundPreciseAnalysis2007>,
    <redelinghuysSymbolicExecutionPrograms2012>,
    <dantoniPowerSymbolicAutomata2017>,
  )

  for label in labels {
    cite(label, style: "council-of-science-editors")
  }
}

Even though SAT is the archetypical NP-complete problem @karpReducibilityCombinatorialProblems1972, which in practice means no universally efficient solution exists, it is often necessary to find specific solutions in a reasonable amount of time. SMT solvers such as Z3 aim to find satisfiable assignments to queries such as $X + Y < 13$ and $X dot Y > 10$. Just Amazon alone does one billion daily SMT queries to verify the correctness of their AWS user policies @rungtaBillionSMTQueries2022, and they are used extensively in many other areas too #other-uses-citation.

As the use-cases become more complex and extensive, better performance is of course desired. While performance gains may come from anywhere, one way to categorize them is between _general purpose_ and _domain-specific_. General purpose improvements usually come in the form of stronger implementations (such as #z3-noodler.display for Z3's strings). However, sometimes there is some exploitable property of a problem or a family of problems that you might want to take advantage of. Z3 provides the _tactics_ mechanism --- where the user can change some behavior of the solver or subdivide the problem --- ostensibly for this reason (even though domain-specific knowledge can also be manifested as additional "refining" constraints, and tactics do not _have_ to be domain-specific)

A question comes to mind when faced with these two approaches: *are there diminishing returns to using domain-specific guidance as the implementation strength increases?* That is, if an SMT implementation is particularly clever and efficient, it might be the case that guiding it is not very helpful, or even counterproductive. For instance, a human that tries to "guide" a strong chess engine will almost certainly make it perform worse, since chess engines are much better than humans. In a similar way, we explore to what extent guiding an SMT solver using domain-specific knowledge contributes more in overhead than in performance improvements.

We hope the findings presented in this paper give insight into how effective guidance is when varying the effectiveness of the underlying solver implementation; for example, helping a researcher working on formal verification to make an informed decision about whether it is more worthwhile to invest time on improving the understanding of a problem, or in running/improving the solver.

== Contributions

In this paper we describe the relationship between solver implementation strength and the effectiveness of domain-specific guidance. The main contributions of the research are: 

+ An automatic procedure to simulate domain-specific knowledge on arbitrarily large datasets while providing similar amounts of help, based on reducing the search space and quantifying the impact. 
+ Insight on how the performance of Z3 changes when using domain-specific guidance.
+ Understanding on how the strength of an underlying implementation affects said change in performance when using domain-specific guidance.
+ A benchmarking suite to test and compare these models, providing 100% reproducible builds of the compared implementations using Nix.

// We first give a quick overview of how the selected solvers work, necessary to understand their behavior, in @theoretical-background. In @methodology and @results[] we discuss methodology and show the results. In @discussion we discuss why we see those results and the insight we can gain before concluding the research in @conclusion.
