#import "/utils.typ": todo, z3str3, z3-noodler, cite-wrong

= Theoretical Background <theoretical-background>

This section provides a quick overview of how a generic SMT solver works and the differentiating features of each solver, as well as other relevant concepts and works referenced in the rest of the paper.

== Anatomy of an SMT solver

The typical way that constraints over strings get resolved Z3 and other solvers is through DPLL(T) constraint propagation @ganzingerDPLLTFastDecision2004 @demouraZ3EfficientSMT2008. It roughly consists in making a decision (i.e., assigning a concrete value) on one variable and propagating the implications of that decision on the rest of the constraints. For example, for two numbers $X$ and $Y$ and constraints $X + Y < 13$ and $X dot Y > 10$ a decision could be assigning $X = 10$ which propagates into $10 + Y < 13 => Y < 3$ and $10 dot Y > 10 => Y > 1$. Then, $Y$ can be assigned as $Y=2$ which successfully finds a satisfiable assignment for this instance. If at any point in the propagation a variable has no possible options, then the last decision is deemed infeasible.

In the case of strings, we can split decisions into the length and the string itself. For instance for a variable $X$ we can make a decision that $|X| = 2$, do the necessary propagation to see if it is infeasible, and then make a decision on a 2-character variable.

Additionally, in practice, many constraints over strings have an analogous linear integer arithmetic (LIA) equation over their lengths. For example, concatenation of strings implies sum of their lengths, i.e.: $X = a plus.double b plus.double c => |X| = |a| + |b| + |c|$ (where $plus.double$ indicates string concatenation and $|dot|$ indicates length).

We show a summarized diagram of the procedure for an SMT problem in @fig-string-solver-diagram.

#figure(
  include "/assets/string-solver-diagram.typ",
  caption: [Generic string solving procedure. Initial constraints imply LIA equations. Lengths that are valid for LIA eqs. are checked and propagated (full propagation procedure not shown). ],

  placement: top,
) <fig-string-solver-diagram>


== String solver implementations <string-solver-implementations>

The two implementations compared in this paper are #z3str3.display and #z3-noodler.display:
- #z3str3.display @berzishZ3str3StringSolver2017 is the official upstream solver used by Z3 since 2017. It generally resembles the standard approach for string solving explained in the previous section, apart from relatively incremental improvements.

- #z3-noodler.display #cite-wrong(<havlenaCookingStringIntegerConversions2024>, <chenZ3NoodlerAutomatabasedString2024>) is the state of the art in string solving and the winner of SMT-COMP 2024 @ResultsSMTCOMP2024. It employs many novel techniques, such as comparing the NFAs that result from regular expressions directly. This, along with other optimizations, are deviations from the standard solving approach, and thus from the mental model of constraint propagation, which makes it harder to predict whether guidance from the user will ultimately be useful.

== _Sat_ vs _unsat_ <sat-vs-unsat>

For each problem, SMT solvers can return one of three results: satisfiable (_sat_), unsatisfiable (_unsat_) or unknown. Unknown gets returned when the solver cannot find a solution, typically because of a timeout, otherwise returning either _sat_ or _unsat_.

While these two cases may look similar, they are fundamentally different. Namely, finding _sat_ is NP-complete, finding _unsat_ is #strong[co]NP-complete @gurComplexityTheoryLecture. On _sat_ cases Z3 returns a model solution (i.e., $X=#quote[hello]$, $Y=#quote[world]$) while on _unsat_ you can get an unsatisfiability core. The helpfulness of the _unsat core_ given by Z3 has no guarantees (in fact, just returning the original problem is perfectly valid), and in practice Z3 seems to struggle with _unsat_. As we will explain in @automatic-simulation-of-domain-specific-knowledge, in this paper we only deal with the _sat_ case.

== Tactics vs domain-specific solver guidance <tactics-vs-domain-specific-knowledge>

It is important to note that tactics and domain-specific solver guidance are not interchangeable in general. Even though the existence of tactics is motivated by the ability to model domain-specific knowledge, one can use tactics in a general-purpose way; and, conversely, one can add domain-specific knowledge without using tactics.

An example of the "general purpose tactics" is _portfolio solving_ @wintersteigerConcurrentPortfolioApproach2009, where the solver tries various tactics in parallel and retrieves the first one, but in fact the contract of a tactic is wide enough to allow one to implement a whole different general-purpose SMT solver such as Cvc5 @barbosaCvc5VersatileIndustrialStrength2022 itself as a "tactic".

And, on the other hand, when modeling a problem, there is often a minimal set of constraints that has the sought-for satisfiability result, but you can add more constraints that reduce/refine the search space (while keeping the same result). Symmetry-breaking constraints are a particularly common example, but they can be arbitrarily complex. The presented research uses this latter approach, which seems to be more common for string solving regardless.

== Other related work

It is common practice to include benchmarks when introducing a new approach for a solver. #z3str3.display and #z3-noodler.display are no exception. #z3str3.display's benchmarks are relatively brief @berzishZ3str3StringSolver2017[pp. 57-58], while #z3-noodler.display's are very extensive, analyzing and explaining each problem set used @chenZ3NoodlerAutomatabasedString2024[pp. 27-30]. The results presented in the paper are somewhere between these two in terms of detail.

There is less research on domain-specific guidance for SMT solvers. In @luLayeredStagedMonte2024 they use a Monte Carlo Tree Search approach to synthesize strategies, and papers like @zhangDeepCombinationCDCLT2024 and @liuLLMEnhancedTheoremProving2024 present machine-learning-based approaches to implement tactics, all of which carry out benchmarks. However, these papers present _general-purpose_ tactics, since their goal is to find a solution faster automatically given the problem. This differs from the topic of this paper, which is simulating what happens when the same solver has additional information about the problem.

Finally, there is research on more general guidance for computer proofs, which overlaps in terms of use-cases with SMT solving. For example, in @koehlerGuidedEqualitySaturation2024 they successfully apply guidance to an automated proving technique known as equality saturation. Most of the research in this area, however, does not have an analogue of different underlying "strength" levels for the computerized proving itself.
