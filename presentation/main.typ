#import "/utils.typ": todo, z3str3, z3-noodler, info, constraints

#import "@preview/touying:0.6.1": *
#import "@preview/pinit:0.2.2": *
#import "@preview/numbly:0.1.0": numbly

#import "/colors.typ": bg, bg2, accent, black, gray

#let handout = sys.inputs.at(default: false, "HANDOUT") == "true"

#import themes.dewdrop: *
#show: dewdrop-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  navigation: "mini-slides",
  mini-slides: (
    height: 2em,
    x: 2em,
    display-section: true,
    display-subsection: true,
    short-heading: false,
    linebreaks: false,
  ),
  config-info(
    title: [*Is solver guidance redundant \ for strong SMT implementations?*],
    subtitle: info.subtitle,
    author: [
      #info.author

      Grading committee: #info.responsible-prof, \ #info.supervisor, #info.examiner
    ],
    institution: [
      *TU Delft*
    ],
  ),
  config-common(
    show-notes-on-second-screen: if handout { none } else { right },
    new-section-slide-fn: none,
    handout: handout,
  ),

  config-colors(
    neutral-darkest: black,
    neutral-light: accent.transparentize(90%),
    neutral-lightest: white,
    primary: accent.darken(82%).rotate(27deg),
  ),

  config-page(fill: bg),
)

#let click = [$diamond$]

#let blue1 = color.oklch(90%, 9%, 60deg)
#let blue2 = color.oklch(75%, 90%, 290deg) // Maybe too saturated
#let black = color.oklch(1%, 93%, 106.41deg)
#let gray = color.oklch(45%, 00%, 0deg)
#let example = color.oklch(70%, 15%, 180deg)
#let note = color.oklch(70%, 15%, 130deg)

#show smallcaps: body => text(font: "Libertinus Serif", body)
#show raw: set text(font: "IosevkaTerm NF")
#set raw(syntaxes: "/assets/smtlib2.sublime-syntax")

#import "@preview/frame-it:1.1.2": *

#let (example, note) = frames(
  example: ("Example", example),
  note: ("Note", note),
)
#show: frame-style(styles.boxy)



#outline-slide()

#title-slide[]

= Context and motivation

== Context & background

#let phrase(body) = {
  show strong: it => text(weight: 900, size: 1em + 12pt, it)
  text(fill: black.transparentize(50%), weight: 100, body)
}

#slide[
  #speaker-note[
    - #todo[]
    - Strong implementations
    - What is the baseline?
    - Z3str3
      - Relatively simple/intuitive
      - Improvement over predecessor: search smaller subtrees first (logical)
    - Z3-Noodler
      - State of the art, winner of smt competition
      - Bunch of features, complex and unintuitive
      - Comparing the NFAs of RegExes directly => different mental model

  ]

  #phrase[Is solver guidance redundant for *strong* SMT *implementations*?]

  #grid(
    inset: 1pt,
    columns: (1fr, 1fr),
    [
      #pause
      *#z3str3.display* (#z3str3.year) @berzishZ3str3StringSolver2017

      #pause
      - Official upstream solver
      #pause
      - Relatively simple and intuitive
      #pause
      - Improvement: Searches smaller subtrees first
    ],
    [
      #pause
      *#z3-noodler.display* (#z3-noodler.year) @chenZ3NoodlerAutomatabasedString2024

      #pause
      - State of the art, winner of SMT-COMP 2024
      #pause
      - Features
        - #smallcaps[Stabilization] procedure
        - Axiom Saturation
        - Nielsen transformation
        - Preprocessing
      #pause
      - Complicated and not intuitive
      #pause
      - Different technique for Regex
    ],
  )
]

== Research question

#slide[
  #speaker-note[
    - We get to the question, is this actually useful for solvers such as Noodler?
    - Maybe it's just not really effective
    - Maybe it's more like chess, actively harmful, even if Magnus Carlsen tries to "guide" an engine it will just make it worse.
    - That's what we want to figure out.

    - Why? well, there are practical usecases
    - Namely, it helps researches like at the PL group to answer investing time in a problem vs just letting run (or even improving it!).
    - But this could also be applied to industry as well as research.
  ]

  #pause
  - Perhaps domain-specific guidance is not that helpful
  #pause
  - Perhaps domain-specific guidance is actively harmful
  #pause

  === Motivation

  #pause
  - Practical use-cases:
    #pause
    - Invest time in problem understanding _vs_ #pause just letting the solver run
    #pause
    - Both for research & industry.
]

= Methodology

#slide[
  #speaker-note[
    - This is an overview of the experiment.
    - We start with a *dataset* of SMT problems, this one is over 100k cases from SMT-LIB
    - Then we *solve* it, without benchmarking, just getting the solutions.
    - Now, this is the *crucial step*: we generate domain-specific constraints from the model solution. This is what simulates domain-specific guidance: we're adding constraints that hint to the solution we obtained.
    - With this, we can *benchmark* how long it takes to solve each problem with and without this help.
  ]

  #import "/assets/workflow-diagram.typ": workflow-diagram
  #box(height: 10%, workflow-diagram())
  #figure(supplement: "Algorithm")[] <algorithm-domain-specific-constraints>
]

== Simulating domain-specific knowledge

#speaker-note[
  - Now, I want to talk a bit more about how we generate these domain-specific constraints
  - Because it's surpisingly tricky!
  - There are 6 types of constraint we add: (name them)
  - The thing is that these are very different, so how do we ensure we give an equal amount of help?
]

#pause
- Surprisingly complicated!

#pause
- Constraints
  #pause
  #for (name,) in constraints {
    [- #name #pause]
  }

- *How to give help fairly?*

#focus-slide[
  #text(size: 1em + 20pt)[Answer: Quantify the help]

  _as the reduction of the search space_
]

- Guesser $G$ chooses a length $ell tilde "Exp"(lambda)$, then a random string of length $ell$.
#pause
- Probability $p$ of guessing solution string $s$
#pause
- Probability $p^*$ of guessing solution given a constraint $*$
#pause

#text(size: 1em + 5pt)[*Help = log-increase of probability*]
#pause
$ h = -(ln(p^*) - ln(p)) / (ln(p)) $
#pause
- `X = "hello"` $=>$ `X startsWith "he"` $approx$ $2 / 5 = 40%$ help
#pause
- Has theoretical justification ("abstract SMT machine").

#speaker-note[
  - In practice this means choosing $ell tilde "Exp"(lambda)$ and substring $|s| = ell$
  - From that $p$, from that $p^*$ (which reduces either $ell$ or $s$)
  - Then we define the help as the log increase. This is the formula.
  - Zooming out, this procedure has sensible results.
    - If we reveal 2 out of 5 chars, we get about $2 / 5 = 40%$ (a bit less in practice).
  - If this sounds out of the blue, there is a justfication speaking about thinking of "Abstract SMT machines". More or less.
  - Iron out a few more details, but these are enough for today.
]

== Reproducibility

#speaker-note[
  - Also, quickly, in terms of reproducibility
  - Seeded, deterministic, portable RNGs
  - Run each case multiple times
  - Package with Nix, so it's trivial to get the exact version we used with a couple of commands.
]

- Seeded, deterministic, portable RNGs
- Run each case multiple times
- Package with Nix

= Results


#slide[
  #pause
  #v(-3cm)
  #align(
    center + horizon,
    {
      set table(inset: 6mm)
      include "/assets/summary.typ"
    },
  )

  #speaker-note[
    - Finally, let's get to results!
    - There's a lot of ways to represent the data
      - A lot of dimensions: solution length, number of constraints...
    - This is the main statistic. The (geometric) mean of speedup, weighed by the runtime because bigger problems have more impact.
    - The results are damming. z3str3 is about 3.3x faster while z3-noodler is, in fact, over 70% _slower_.
    - Even in unweighted, z3-noodler is a lot slower than z3str3 but also z3str3 seems to have a slowdown?
  ]
]


#slide(
  repeat: 7,
  config: (footer: none),
  self => [
    #let (uncover, only, alternatives) = utils.methods(self)

    #speaker-note[
      - *Important trend* in the data: the approach of "reducing the search space" adding constraints improves as the problems get harder.
      - But, *conversely, for small, fast cases *there is more overhead than improvement. Think of it as the *slowdown zone*.
      - With this, we can talk about the two reason why Z3-noodler sees huge improvements.
        1. For one, it's so fast that it never leaves the "slowdown zone"! (perhaps you saw it before, but there is no purple dot above a second or two)
        2. For two, often the additional constraints are just actively harmful! (see how it goes in the red at about 1ms).
      - So in conclusion, yes, \<read slide\> #todo[Extrapolating?]
    ]

    #list(
      uncover("2-")[
        "Reducing the search space" improves as the problems get harder
        - #uncover("3-")[Adds overhead to small, fast cases (the "slowdown zone").]
      ],
    )

    #only("4-")[
      #list([
        #z3-noodler.display sees _huge_ (70%!) slowdowns with domain-specific help, because...
        + #uncover("5-")[...it is already fast, so it doesn't leave the "slowdown zone"]
        + #uncover("6-")[...the additional constraints actively harm performance]
      ])
    ]

    #only("7-")[
      #linebreak()
      - *There does seem to be diminishing returns to \ domain-specific guidance as solvers get stronger*
    ]

    #only("2-3")[#image(
        "/assets/plots/speedup-vs-original-linear.svg",
        height: 70%,
      )]

    #only("5")[
      #place(
        dy: -4mm,
        center,
        image(
          "/assets/plots/speedup-vs-original-linear.svg",
          height: 69%,
        ),
      )
    ]

    #only("6")[
      #place(
        center,
        image(
          "/assets/plots/new-vs-original-heatmaps.svg",
          height: 68%,
        ),
      )
    ]
  ],
)

== Limitations & looking forward

- Test more implementations and more theories.
- Test higher runtimes for #z3-noodler.display.
- Understand how exactly do these constraints harm performance.
- Add support for "soft constraints".
- Apply procedure to unsatisfiable cases.

#speaker-note[
  - Test more implementations and more theories.
  - Test higher runtimes for #z3-noodler.display (tricky because long runtimes for #z3-noodler.display generally imply _very_ long runtimes for #z3str3.display).
  - Understand how exactly do these constraints harm performance.
  - Add support for "soft constraints".
  - Apply procedure to unsatisfiable cases.

  - I will be glad to see any future work on the area, perhaps in an upcoming bachelor thesis, but for today this is all I had.
]

#focus-slide[Thank you for listening!]

#heading(outlined: false, bookmarked: false, level: 1, depth: 3)[Bibliography]
#bibliography("/references.bib", title: none)

#align(center, text(size: 1em + 28pt)[*Questions?*])

#let poster_path = sys.inputs.at(default: "/build/poster.png", "POSTER_PATH")
#if poster_path != "" {
  focus-slide(config: (config-page(fill: bg)))[
    #image(height: 134%, poster_path)
  ]
}

#heading(depth: 1, outlined: false, bookmarked: false)[Extra slides]

#slide[
  *How an SMT string solver works*

  #set text(size: 11pt)
  #align(center, include "/assets/string-solver-diagram.typ")
]

#slide[
  *How #z3str3.display works*

  - Theory aware branching and case splitting
  - Example (from original paper @berzishZ3str3StringSolver2017)

  $
    X plus.double Y = A plus.double B => cases(
      X = A and Y = B,
      X = A plus.double s_1 and s_1 plus.double Y = B,
      X plus.double s_2 = A and Y = s_2 plus.double B
    )
  $

  - Always check first case, since it's the simplest.
  - Let Z3 know about more stuff like this down the tree.
]

#slide[
  *How #z3-noodler.display works*

  #image("/assets/z3-noodler-arch.jpg")
]

#slide[
  *_Tactics_ vs domain-specific guidance*

  - Tactics are ostensibly for domain-specific guidance, but...
    - Tactics _can_ be general purpose
    - Domain-specific guidance is not _always_ tactics.
]

#slide[
  *Dataset used*

  - SMT-LIB2 dataset for strings. Specifically:
    - Non incremental
    - `QF_S` (quantifier free strings)
    - `QF_SLIA` (quantifier free string with linear integer arithmetic)
    - `QF_SNIA` (quantifier free strings with nonlinear integer arithmetic)
  - Discarded unsat cases.
]

#slide[
  *Applying constraints*

  - Parameter values
    - $lambda = ln((|s|) / (|s| + 1))$
    - $C = 3 dot 16^4 = 196.608$, could also be number of unique characters in $s$
      - In log increase, it has little effect (in linear increase, it's humongous).
  - Reach desired help by repeatedly undershooting constraints.
]

#slide[
  #set par(leading: 3pt, spacing: 14pt)
  *Full constraint-parameter equations*

  #{
    set math.equation(numbering: none)
    set text(size: 1em - 1pt)
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
]

#slide[
  #speaker-note[
    - In practice *and in my discussion with teammates*, Z3 is bad with unsat
  ]
  *The _unsat_ case*

  - Superficially similar, fundamentally different:
    - NP vs #strong[co]NP
    - $forall$ vs $exists$
    - Model (fully determined) vs unsatisfiability core (can be the original problem)
  - It is dubious to apply the same reasoning, but it might just work

  - In practice, Z3 is bad with _unsat_.
]

#slide[
  *Benchmarking details*

  #import "/assets/notes.typ": running, setup

  #grid(
    columns: (1fr, 1fr),
    gutter: 1cm,
    setup(), running(),
  )
]

#slide[
  *"Abstract SMT machine"? What do you mean?*


  #align(
    center,
    {
      set text(size: 11pt)
      include "/assets/string-solver-diagram.typ"
    },
  )

  - Solvers "want" to try small lengths, but with a "chance" they fail.
  - Perhaps a bastardization of "Abstract Turing Machine" (recognizable/undecidable instead of probably NP/coNP (but that seems also unclear)).
]

#slide[
  *Why wouldn't you always optimize the general case?*

  - The "general" case for a specific problem is improving the problem, and from that perspective improving the problem is the specific solution.
]

