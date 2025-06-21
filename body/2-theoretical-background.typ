#import "/utils.typ": todo, z3str3, z3-noodler
#let tc = todo[cite]

= Theoretical Background <theoretical-background>

This section provides a quick overview of how an SMT solver works in general and the "flagship" features of each solver to get a preliminary grasp of their behaviors. To fully understand them, the original papers (cited accordingly) should be visited; but the information in this section should be enough to understand the results in this paper. 

== Anatomy of an SMT string solver

The fundamental way that constraints over strings get solved by something like Z3 is by lowering the constraints into bitvector and linear integer arithmetic (LIA) equations. A string is a sequence of $n$ characters, and each character can be modeled as a bitvector. Most SMTLIB constraints on strings have an analogous LIA equation over lengths. For example, concatenation of strings implies sum of their lengths, i.e.: $X = a plus.double b plus.double c => |X| = |a| + |b| + |c|$ (where $plus.double$ indicates string concatenation and $|dot|$ indicates length).

And then, for each length, the strings can be constrained character-by-character interpreting the characters as bitvectors.

Once the constraints are lowered, Z3 uses the standard DPLL(T) @ganzingerDPLLTFastDecision2004 for constraint propagation, which largly consists on setting a variable to a value and inferring how other variables are constrained based on that choice.

== String solver implementations <string-solver-implementations>

The two following string solver implementations where used to carry out the experiments:

#let describe-impl(impl, citation, body) = [
  - #text(fill: impl.color.darken(30%))[*#impl.display (#impl.year)*] #cite(citation): #body
]

#describe-impl(z3str3, <berzishZ3str3StringSolver2017>)[
  This is the implementation used upstream by Z3 at the time of writing. It is based on propagating higher level information about the theory of strings when branching and case-splitting, such as searching simpler cases first or propagating the fact that a case-split is exclusive down in the search tree @berzishZ3str3StringSolver2017[pp.~55-56].
]

#describe-impl(z3-noodler, <chenZ3NoodlerAutomatabasedString2024a>)[
  #z3-noodler.display was the winnner of SMT-CMP's 2024 string track. It uses a novel technique called #smallcaps[Stabilization], introduced by #cite(form: "prose", <blahoudekWordEquationsSynergy2023>) and #todo[explain stabilization and general working of z3-noodler].
]

== Tactics vs domain-specific solver guidance <tactics-vs-domain-specific-knowledge>

It is important to note that tactics and domain-specific solver guidance are not interchangeable in general. Even though the existence of tactics is motivated by the ability to model domain-specific knowledge, one can use tactics in a general-purpose way; and, conversely, one can add domain-specific knowledge without using tactics.

An example of the "general purpose tactics" is _portfolio solving_, where the solver tries various tactics in parallel and retrieves the first one #tc, but in fact the contract of a tactic is wide enough to allow one to implement a whole different general-purpose SMT solver such as Cvc5 @barbosaCvc5VersatileIndustrialStrength2022 itself as a "tactic".

And, on the other hand, when modelling a problem, there is often a minimal set of constraints that has the sought-for satisfiablity result, but you can add more constraints that reduce/refine the search space (while keeping the same result).  Symmetry-breaking constraints are a particularly common example, but they can be arbitrarily complex. 

// #todo[Add new example (in code comments)]
// NOTE: Maybe a quick but compelling example for the presentation or for the paper is proving there are infinite even numbers. One way to do that is that for every even number, there is an even number after that. SMT solvers can't do a forall, tho, only exists, so if anything you want to do a not exists which makes a forall. Then, you need to negate the inside expression so the statement you give to the solver is that there exists a maximum even number and the solver should spit out `unsat`. As it stands, it will take forever. You could just prove it by hand or... you could say that you only need to prove that one even number exists, and then that by induction infinite exist.

// An argument can be made that improving just a single problem using domain-specific knowledge is clearly worse. After all, if you make the general purpose solver better, even if by a miniscule amount, it is going to be multiplied by all the uses of the solver which will quickly give you much more improvements than you could ever hope for a single optimization. This is not entirely false, but it overlooks two points. Firstly, there are certain problems that cannot feasibly complete in time, and better general-purpose computation does not solve this; but secondly and more importantly, from the perspective of the specific problem, improving the solver in general is the "specific" optimization and understanding the problem better is the "general" and more sought after improvement. It's a matter of perspective. #todo[Dennis: fluffy.]

// So, to be clear, this paper is concerned with domain-specific knowledge, not exclusively tactics.


== Other related work

#todo[Improve paragraph] It is common practice to include benchmarks when introducing a new approach for a solver. #z3str3.display and #z3-noodler.display are no exception. #z3str3.display's benchmarks are relatively brief @berzishZ3str3StringSolver2017[pp. 57-58], while #z3-noodler.display's are very extensive, analyzing and explaining each problem set used @chenZ3NoodlerAutomatabasedString2024[pp. 27-30]. The results presented in the paper are somewhere between these two in terms of detail.

There is less research on domain-specific guidance. In @luLayeredStagedMonte2024 they use a Monte Carlo Tree Search approach to synthesize strategies, and papers like @zhangDeepCombinationCDCLT2024 and @liuLLMEnhancedTheoremProving2024 present machine-learning-based approaches to implement tactics, all of which carry out benchmarks. However, these papers present _general-purpose_ tactics, since their goal is to find a solution faster automatically given the problem. This differs from the topic of this paper, which is simulating what happens when the same solver has additional information about the problem. In fact, this particular topic seems virtually unexplored, so we hope we shine some light on it in this paper.

#todo[Would be nice to expand this section...]
