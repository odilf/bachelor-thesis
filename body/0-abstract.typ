#import "/utils.typ": todo, z3str3, z3-noodler

#let text = [
  The Z3 SMT solver, a kind of satisfiability solver used both in research and in industry, can give better performance by either improving the underlying implementation or using domain-specific guidance. We present a way to simulate domain-specific help automatically by reducing the search space based on the model solution, and we use it to comprare two implementations of Z3's string solver -- #z3str3.display (weaker) and #z3-noodler.display (stronger) -- with and without domain-specific help. #z3-noodler.display sees significantly less improvement than #z3str3.display because 1) the additional "helping" constraints are in fact occasionally counterproductive and 2) #z3-noodler.display solves equivalent problems much faster than #z3str3.display, so the relative overhead of the additional constraints is more noticed.
]

// We found that the improvements generally exist but are inconsistent in both models; and that the stronger implementation (#z3-noodler.display) sees significantly less improvement in general. We conclude that it is necessary to understand the inner workings of a solver to be able to have confidence that some guidance for a specific problem will be fruitful, and especially so for stronger implementations.

#align(
  center,
  box(
    width: 90%,
    align(
      left,
      [#[*Abstract*: #text] <ignore-word-count> ],
    ),
  ),
)
