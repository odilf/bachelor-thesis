#import "/utils.typ": todo, z3str3, z3-noodler, info, constraints

#import "@preview/touying:0.6.1": *
#import "@preview/pinit:0.2.2": *
#import "@preview/numbly:0.1.0": numbly

#import themes.dewdrop: *
// #show: magic.bibliography-as-footnote.with(bibliography("/references.bib", title: none))
#show: dewdrop-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  navigation: "mini-slides",
  primary: oklch(26.37%, 14%, 264.86deg),
  config-info(
    title: [#info.title],
    subtitle: info.subtitle,
    author: [
      #info.author

      Grading committee: #info.responsible-prof, #info.supervisor, #info.examiner
    ],
    // date: datetime.today(),
    institution: [
      *EEMCS Faculty Delft University of Technology*

    ],
  ),
  config-common(
    // bibliography-as-footnote: biliography(title: none, "/references.bib"),
    show-notes-on-second-screen: right,
    // handout: true,
  ),
)

#let click = [$diamond$]

#let blue1 = color.oklch(90%, 9%, 60deg)
#let blue2 = color.oklch(75%, 90%, 290deg) // Maybe too saturated
#let black = color.oklch(1%, 93%, 106.41deg)
#let gray = color.oklch(45%, 00%, 0deg)
#let example = color.oklch(70%, 15%, 180deg)
#let note = color.oklch(70%, 15%, 130deg)

// #set text(
//   // fill: black,
//   // size: 32pt,
//   font: "Lora",
// )
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

= What and why

== Context

#let phrase(body) = {
  show strong: it => text(weight: 900, size: 1em + 12pt, it)
  text(fill: black.transparentize(50%), weight: 100, body)
}

#slide[
  #speaker-note[
    - Let's start by breaking down the question
    - We've already seen what SMT solvers are
  ]

  #phrase[Is *solver* guidance redundant for strong *SMT* implementations]

  - SAT on steroids (i.e., theories)
]

#slide[
  #speaker-note[
    - Strong implementations
    - What is the baseline?
    - Z3str3
      - Flagship: search smaller subtrees first
      - Relatively simple/intuitive
    - Z3-Noodler
      - State of the art
      
  ]

  #phrase[Is solver guidance redundant for *strong* SMT *implementations*]

  #grid(
    inset: 1pt,
    columns: (1fr, 1fr),
    [
      #pause
      *#z3str3.display* (#z3str3.year) @berzishZ3str3StringSolver2017

      #pause
      - Official upstream solver
      #pause
      - Searches smaller subtrees first
      #pause
      - Relatively simple/intuitive
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
    ],
  )
]

#slide[
  #phrase[Is *solver guidance* redundant for strong SMT implementations]

  #pause
  - Not necessarily tactics

  #pause
  - Additional constraints, e.g.,
    #pause
    - Length of $x$ is less than $100$
    #pause
    - String $y$ will always start with $#quote[http]$
    
]

#slide[
  #speaker-note[
    - We get to the question, is this actually useful for solvers such as Z3 Noodler?
    - Maybe it's just not really effective
    - Maybe it's more like chess, actively harmful, even if Magnus Carlsen tries to "guide" an engine it will just make it worse, because they're so much better than humans.
    - That's what we want to figure out.
  ]
  #phrase[*Is* solver guidance *redundant for* strong SMT implementations]

  #pause
  - Is domain-specific guidance not helpful?
  #pause
  - Is domain-specific guidance actively harmful?
]

== Motivation

#speaker-note[
  - Why are we doing this? Even though I like "knowledge for the sake of knowledge", unfortunetaly there are practical use-cases.
  - Namely, it helps to answer the question of investing time in a problem vs just letting the solver run longer.
  - This can be applied to both research and industry.
]

#pause
- Practical use-cases:
  #pause
  - Invest time in problem understanding _vs_ #pause just letting the solver run
  #pause
  - Both for research & industry.

= How

#slide[
  #speaker-note[
    - This is an overview of the experiment.
    - We start with a dataset of SMT problems, this one is over 100k cases from SMT-LIB
    - Then we solve it, without benchmarking, just getting the solutions.
    - Now, this is the crucial step: we generate domain-specific constraints from the model solution. This is what simulates domain-specific guidance: we're adding constraints that hint to the solution we obtained.
    - With this, we can benchmark how long it takes to solve each problem with and without this help.
  ]

  #box(height: 10%, include "/assets/workflow-diagram.typ")
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

- How to give help fairly?

#focus-slide[
  #text(size: 1em + 20pt)[Answer: Quantify the help]

  _as the reduction of the search space_
]

- Guesser $G$ chooses a length $ell$ from $"Exp"(lambda)$, then a random string of length $ell$.
#pause
- Probability $p_s$ of guessing solution string $s$
#pause
- Probability $p_s^*$ of guessing solution given a constraint $*$
#pause

#text(size: 1em + 5pt)[*Help = log-increase of probability*]
#pause
$ h = -(ln(p_s^*) - ln(p_s)) / (ln(p_s)) $
#pause
- `X = "hello"` $=>$ `X startsWith "he"` $approx$ $2/5 = 40%$ help
#pause
- Has theoretical justification ("abstract SMT machine").

#speaker-note[
  - You need a to iron out a few more details, but this is enough detail for today.
]

== Reproducibility

#note[Reproducibility][
  #table(
    columns: (5cm, auto),
    stroke: none,
    inset: 0cm,
    align(
      horizon,
      image(
        width: auto,
        "/assets/nix-logo.svg",
      ),
    ),
    box(inset: (left: 1cm))[#set text(size: 1em + 9pt)
      Everything is packaged with Nix, so you can easily reproduce the testing environment with 100% accuracy.],
  )
]

= Results

#slide(
  repeat: 8,
  self => [
    #let (uncover, only, alternatives) = utils.methods(self)

    #speaker-note[
      - There's a lot of ways to represent the data
      - If you're curious about some other dimension, feel free to ask a question.
    ]

    #list(
      uncover("2-")[
        "Reducing the search space" improves as the problems get harder
        - #uncover("3-")[Adds overhead to small, fast cases (the "slowdown zone").],
      ],
    )

    #only("4-")[
      #list([
        #z3-noodler.display sees _huge_ (70%!) slowdowns with domain-specific help, because...
        + #uncover("5-")[...it is already fast, so it doesn't leave the "slowdown zone"]
        + #uncover("6-")[...the additional constraints actively harm performance]
      ])
    ]

    // #only("7-")[
    //   - You need to understand the solver implementation to confidently make optimizations! \ #uncover("6-")[(i.e., _predicting performance is hard_)]
    // ]
    #only("7-")[
      #linebreak()
      - *There does seem to be diminishing returns to \ domain-specific guidance as solvers get stronger*
    ]

    #only("2-3")[#image(
        "/assets/plots/speedup-vs-original-linear.svg",
        height: 70%,
      )]

    #only("5")[#image(
        "/assets/plots/speedup-vs-original-linear.svg",
        height: 40%,
      )]

    #only("6")[#image(
        "/assets/plots/new-vs-original-heatmaps.svg",
        height: 40%,
      )]
  ],
)

== Limitations & looking forward

- More implementations, more theories! #pause
- How exactly do these constraints harm performance? #pause
- Add support for "soft constraints"

#focus-slide[Thank you for listening!]

#bibliography("/references.bib")

#heading(depth: 1, outlined: false, bookmarked: false)[Extra slides]

#slide[
  *How an SMT string solver works*
]

#slide[
  *How #z3str3.display works*
]

#slide[
  *How #z3-noodler.display works*
]

#slide[
  *_Tactics_ vs domain-specific guidance*
]

#slide[
  *Dataset used*
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
  *Full constraint-parameter equations*
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
]

#slide[
  #todo[More plots?]
]

#slide[
  *Why wouldn't you always optimize the general case?*
]

