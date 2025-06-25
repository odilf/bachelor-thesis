#import "/utils.typ": todo, z3str3, z3-noodler, constraints, info
#import "/assets/workflow-diagram.typ": workflow-diagram
#import "/assets/notes.typ" as notes

#import "/colors.typ": bg, bg2, accent, accent, accent, black, gray

#set page(
  paper: "a0",
  flipped: true,
  margin: (
    x: 3cm,
    bottom: 3cm,
    top: 0cm,
  ),
  columns: 3,
  fill: gradient
    .linear(
      (bg2, 0%),
      (bg, 80%),
      (accent.transparentize(30%), 100%),
      angle: 70deg,
    )
    .sharp(42, smoothness: 0%),
)

#set par(justify: true)

#set text(
  fill: black,
  size: 32pt,
)
#show smallcaps: body => text(font: "Libertinus Serif", body)
#show raw: set text(font: "IosevkaTerm NF")
#show figure: it => {
  show figure.caption: set text(1em - 6pt)
  it
}
#set raw(syntaxes: "/assets/smtlib2.sublime-syntax")

#set heading(numbering: "1.")
#show heading: it => [
  #it
  #place(
    line(length: 80%, stroke: (paint: black, thickness: 6pt, cap: "round")),
  )
  #v(1cm)
]

#place(
  top,
  scope: "parent",
  float: true,
  text(2em)[
    #let height = 7cm
    #let width = 65%
    #let slope_width = 5cm
    #let x-margin = 4cm

    #place(
      curve(
        fill: accent.desaturate(90%),
        curve.move((0% - x-margin, 0%)),
        curve.line((0% - x-margin, height)),
        curve.line((width - slope_width, height)),
        curve.line((width, 0%)),
        curve.close(),
      ),
    )

    #place(
      curve(
        fill: accent.desaturate(85%),
        curve.line((width - slope_width, height)),
        curve.line((width, 0%)),
        curve.close(),
      ),
    )

    #place(
      curve(
        fill: accent.darken(95%).desaturate(60%),
        curve.move((width, 0cm)),
        curve.line((width - slope_width, height)),
        curve.line((100% + x-margin, height)),
        curve.line((100% + x-margin, 0%)),
      ),
    )

    #grid(
      columns: (66cm, 1fr),
      [
        #v(1.5cm)
        *#info.title* \
        #text(size: 0.9em)[An exploration of Z3's strings.]

        #v(1cm)
      ],
      align(right)[
        #let mail = text(
          size: 1em - 35pt,
          fill: white.transparentize(50%),
          link(
            "mailto:o.machairas@student.tudelft.nl",
            "o.machairas@student.tudelft.nl",
          ),
        )
        #v(1.3cm)
        #set text(fill: white)
        #set par(leading: 8mm)
        *Odysseas Machairas* \
        #mail \
        #set text(size: 1em - 27pt)
        Supervised by D. Sprokholt and S. Chakraborty, TU Delft
      ],
    )
  ],
)


= Context and motivation

#let speaker-note(body) = []
#let pause = []

Z3 @demouraZ3EfficientSMT2008 is an SMT @barrett2010smt solver, which finds satisfiable assignments to queries such as, for two numbers $X$ and $Y$, $X + Y > 13$ and $X dot Y < 10$. This is a generalization of SAT, the archetypal NP-complete problem, which means that universally efficient solutions likely don't exist. Despite this, Z3 aims to quickly find answers to such questions.

There are two ways to improve performance:

#grid(
  columns: (3fr, 2fr),
  gutter: 85pt,
  [
    *Domain-specific guidance*

    Understand the structure of a problem, change the strategy of the solver (aka _tactics_, in Z3) or add constraints that refine the search space.
  ],
  [
    *General purpose \ improvements*

    Make the solver better for most problems.
  ],
)

Given these two approaches, we ask whether _domain-specific_ guidance becomes less useful if the underlying implementation is stronger in general (e.g., analogous to "helping" a chess engine, which is futile). Namely, we compare:

#grid(
  inset: 1pt,
  columns: (0.8fr, 1fr),
  [
    #pause
    *#z3str3.display* (#z3str3.year) @berzishZ3str3StringSolver2017

    - Official Z3 upstream solver
    - Searches smaller subtrees first
    - Relatively simple/intuitive
  ],
  [
    *#z3-noodler.display* (#z3-noodler.year) @chenZ3NoodlerAutomatabasedString2024

    - State of the art, winner of SMT-COMP 2024
    - Compares NFAs from regular expressions directly, and many other improvements
    - Complicated and not intuitive
  ],
)

- *Practical use-cases*:
  - Whether to invest time in problem understanding _vs_ just letting the solver run (or improving it).
  - General understanding of how the solvers behave when guided.
  - Both for research & industry.

= Methodology

We ran an experiment on the SMT-LIB2 dataset for strings. Namely, we simulated domain-specific knowledge by adding constraints based on the solutions, which quickly cuts off infeasiable branches in regular constraint propagation.

#box(
  width: 100%,
  {
    set text(size: 1em - 4pt)
    align(center, workflow-diagram(tight: true, bg: bg))
  },
)
#figure(supplement: "Algorithm")[] <algorithm-domain-specific-constraints>

== Simulating domain-specific knowledge

- There are many constraints
  #set text(size: 1em - 5pt, fill: black.transparentize(30%))
  (#constraints.map(c => c.name).join(", "))

- Question: How to give help fairly?
- Answer: Quantify the help, as the reduction of the search space
  - Guesser $G$ chooses a length $ell$ from $"Exp"(lambda)$, then a random string of length $ell$.
  - Probability $p_s$ of guessing solution string $s$
  - Probability $p_s^*$ of guessing solution given a constraint $*$
  - #text(size: 1em + 5pt)[*Help = log-increase of probability*]
$ h = -(ln(p_s^*) - ln(p_s)) / (ln(p_s)) $

- Sensible results in practice: `X = "hello"`, then help of `X startsWith "he"`
  - Expected $tilde 2 / 5 = 40%$
  - Actual value: $38.87%$

#grid(
  columns: (1fr, 1fr),
  gutter: 25pt,
  notes.setup(), notes.running(),
)

= Results

We find that #z3str3.display is sped up more and more consistently than #z3-noodler.display, as per @table-summary.

#figure(
  {
    set table(inset: 6mm)
    include "/assets/summary.typ"
  },
  caption: [Mean speedups of average runtime with vs without help, \ weighted by the original runtime (without help) and equally.],
) <table-summary>

Observations:
- "Reducing the search space" improves as the problems get harder (@fig-mean-speedup-vs-original-linear), since it adds overhead to small, fast cases (the "slowdown zone").
- #z3-noodler.display sees _huge_ (70%!) slowdowns with domain-specific help, because...
+ ...it is already fast, so it doesn't leave the "slowdown zone" (@fig-mean-speedup-vs-original-linear)
+ ...the additional constraints actively harm performance (@fig-new-vs-original)

#linebreak()
- #set text(
    size: 1em + 8pt,
  ); Overall, *there does seem to be diminishing returns to \ domain-specific guidance as solvers get stronger*

#figure(
  image(width: 100%, "/assets/plots/speedup-vs-original-linear.svg"),
  caption: [Speedup vs original time for #z3str3.display and #z3-noodler.display. Shaded area indicates slowdown. (density at the start not accurately represented)],
) <fig-mean-speedup-vs-original-linear>


#figure(
  image(
    width: 100%,
    "/assets/plots/new-vs-original-heatmaps.svg",
  ),
  caption: [Heatmap comparison of runtime with and without help. Shaded area indicates slowdowns, diagonal line corresponds to no change in performance. $mu_"diff"$ is the mean of the difference of the runtimes.],
) <fig-new-vs-original>

== Limitations & future recommendations

- Test more implementations and more theories.
- Test higher runtimes for #z3-noodler.display (tricky because long runtimes for #z3-noodler.display generally imply _very_ long runtimes for #z3str3.display).
- Understand how exactly do these constraints harm performance.
- Add support for "soft constraints".
- Apply procedure to unsatisfiable cases.

#v(1fr)
#set text(size: 1em - 10pt)
#bibliography("/references.bib")

