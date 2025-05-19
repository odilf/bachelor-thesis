#import "/utils.typ": todo, z3str3, z3-noodler
#let tc = todo[cite]

= Theoretical Background <theoretical-background>

This section provides a quick overview of how an SMT solver works in general, and the "flagship" features of each solver, to be
. For the in-depth explanations we direct the reader to the original cited #todo[Does this sound confusing? As if I'm linking to the paper that was cited originally, instead of the original paper, that I have cited?] papers.

== Anatomy of an SMT string solver

The fundamental way that constraints over strings get solved by something like Z3 is by lowering the constraints into bitvector and linear integer arithmetic (LIA) equations. A string is a sequence of $n$ characters, and each character can be modeled as a bitvector. Most SMTLIB constraints on strings ha . A few examples:
#todo[Choose one alternative.]
- `(= X (str.++ a b c))` $=>$ `(= (str.len X) (+ (str.len a) (str.len b) (str.len c))`
- $x = #raw("str.++") (a, b, c) => #raw("len") (x) = #raw("len") (a) + #raw("len") (b) + #raw("len") (c)$
- $x = #raw("str.++") (a, b, c) => "len"(x) = "len"(a) + "len"(b) + "len"(c)$
- $X = "str.++"(a, b, c) => "len"(X) = "len"(a) + "len"(b) + "len"(c)$
- $X = plus.double (a, b, c) => "len"(X) = "len"(a) + "len"(b) + "len"(c)$
- $X = a plus.double b plus.double c => "len"(X) = "len"(a) + "len"(b) + "len"(c)$

And then, for each length, the strings can be constrained character-by-character interpreting the characters as bitvectors.

Once the constraints are lowered, Z3 uses DPLL(T) for constraint propagation @ganzingerDPLLTFastDecision2004, which is standard. We won't explain how this works because, in practice, it is rarely relevant for understanding and optimizing string solving. 

== String solver implementations <string-solver-implementations>

We have chosen three string solver implementations, starting from the upstream implementation from 2017 and ending at the winner of SMT-CMP of 2024. 

#let describe-impl(impl, body) = [
  - *#impl.display (#impl.year)*: #body
]

#describe-impl(z3str3)[
  This is the implementation used upstream by Z3 at the time of writing #tc. It is based on propagating higher level information about the theory of strings when branching and case-splitting, such as searching simpler cases first or propagating the fact that a case-split is exclusive down in the search tree @berzishZ3str3StringSolver2017[pp.~55-56].
]

#todo[z3-trau]

#describe-impl(z3-noodler)[
  #z3-noodler.display was the winnner of SMT-CMP 2024 #tc. It uses a novel technique called #smallcaps[Stabilization], introduced by #cite(form: "prose", <blahoudekWordEquationsSynergy2023>) and #todo[what do they do?]. #todo[explain stabilization too].
]

== Tactics vs domain-specific solver guidance <tactics-vs-domain-specific-knowledge>

It is important to note that tactics and domain-specific solver guidance are not interchangeable in general. Even though the existence of tactics is motivated by the ability to model domain-specific knowledge, one can use tactics in a general-purpose way; and, conversely, you can add domain-specific knowledge using tactics _per se_.

An example of the "general purpose tactics" is _portfolio solving_, where the solver tries various tactics in parallel and retrieves the first one #tc, but in fact the definition/contract#todo[just keep one, probably] of a tactic is wide enough to allow one to implement a whole different general-purpose SMT solver such as CVC5 as a Z3 itself as a "tactic".

And, on the other hand, when modelling a problem, there often is a minimal set of constraints that has the sought for satisfiablity result, but you can add more constraints that reduce/refine the search space (while keeping the same result).  Symmetry-breaking constraints are a particularly common/easy#todo[easy is more what I want to say but it sounds unprofessional] example, but it can be arbitrarily complex.

// NOTE: Maybe a quick but compelling example for the presentation or for the paper is proving there are infinite even numbers. One way to do that is that for every even number, there is an even number after that. SMT solvers can't do a forall, tho, only exists, so if anything you want to do a not exists which makes a forall. Then, you need to negate the inside expression so the statement you give to the solver is that there exists a maximum even number and the solver should spit out `unsat`. As it stands, it will take forever. You could just prove it by hand or... you could 

So, to be clear, this paper is concerned with domain-specific knowledge, not necesarilly tactics. The objective is to, say #todo[Is this too informal?], help a researcher working on formal verification to make an informed decision about whether it is more worthwhile to invest on improving the understanding of a problem or the solver itself. 
