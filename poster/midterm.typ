#let todo = body => text(fill: red)[*TODO*: #body]

// #let blue1 = color.oklch(20%, 2%, 60deg)
// #let blue2 = color.oklch(25%, 8%, 290deg)
// #let black = color.oklch(99%, 3.21%, 106.41deg)
#let blue1 = color.oklch(98%, 3%, 60deg)
#let blue2 = color.oklch(75%, 90%, 290deg) // Maybe too saturated
#let black = color.oklch(1%, 93%, 106.41deg)
#let gray = color.oklch(45%, 00%, 0deg)
#let example-color = color.oklch(70%, 15%, 180deg)
#let note-color = color.oklch(70%, 15%, 130deg)

#set page(
  paper: "a0",
  flipped: true,
  margin: (
    x: 3cm,
    bottom: 3cm,
    top: 0cm,
  ),
  columns: 4,
  fill: gradient
    .linear(
      (blue1.desaturate(20%).lighten(50%), 0%),
      (blue1, 80%),
      (blue2, 100%),
      angle: 70deg,
    )
    .sharp(20, smoothness: 00%),
)

#set text(
  fill: black,
  size: 32pt,
  font: "Lora",
)
#show smallcaps: body => text(font: "Libertinus Serif", body)
#show raw: set text(font: "IosevkaTerm NF")
#set raw(syntaxes: "/assets/smtlib2.sublime-syntax")

#set heading(numbering: "1.")
#show heading: it => [
  #it
  #place(
    line(length: 80%, stroke: (paint: black, thickness: 6pt, cap: "round")),
  )
  #v(1cm)
]

#import "@preview/frame-it:1.1.2": *

#let (example, note) = frames(
  example: ("Example", example-color),
  note: ("Note", note-color),
)
#show: frame-style(styles.boxy)

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
        fill: blue2.desaturate(90%),
        curve.move((0% - x-margin, 0%)),
        curve.line((0% - x-margin, height)),
        curve.line((width - slope_width, height)),
        curve.line((width, 0%)),
        curve.close(),
      ),
    )

    #place(
      curve(
        fill: blue2.desaturate(85%),
        curve.line((width - slope_width, height)),
        curve.line((width, 0%)),
        curve.close(),
      ),
    )

    #place(
      curve(
        fill: blue2.darken(95%).desaturate(60%),
        curve.move((width, 0cm)),
        curve.line((width - slope_width, height)),
        curve.line((100% + x-margin, height)),
        curve.line((100% + x-margin, 0%)),
      ),
    )

    #box(width: 100%)[
      #v(1.5cm)
      *Is domain-specific guidance redundant with strong SMT solvers?* \
      #text(size: 0.9em)[An exploration of Z3's strings.]

      #v(1cm)
    ]
  ],
)


= What is Z3? #text(size: 1em - 8pt, fill: note-color)[_(and why should I care?)_]
#todo[is this too informal?]

Z3 is an SMT solver, which tries to efficiently find whether an expression can have satisfiable assignments. Yes, that infamous NP-complete problem, the hardest kind of problem that has quickly verifiable solutions. #todo[here i repeat "problem" twice]

SMT solvers are SAT solvers designed to be efficient, using backing theories of specific types, such as floats, bitvectors and strings.

Even though it's hard, it's often essential to find solutions to SAT problems quickly. Amazon alone does a billion queries a day to string solvers @rungtaBillionSMTQueries2022.

= Improving performance: stronger implementation vs solver guidance

To find more solutions fasters, you can either optimize the underlying implementation of the solver theory, or use _tactics_. Z3 provides the tactics mechanism to let the user guide the solver, generally using domain-specific knowledge for a problem in particular.

#example[Verifying lack of malicious URLs][#{
    import "@preview/pinit:0.2.2": *

    show raw: it => {
      set text(size: 1em + 2pt)
      show regex("pin\d"): it => pin(eval(it.text.slice(3)))
      it
    }

    // TODO: I have no idea if this syntax is actually correct
    v(3cm)
    ```smt2
    (sequence
      pin1(add-bounds (starts-with "http" url))pin2
      pin3(timeout 20ms identity)pin4)
    ```
    pinit-highlight(1, 2, stroke: gray)
    pinit-point-from(
      (1, 2),
      pin-dx: -2em,
      body-dx: 0em,
      offset-dx: 0em,
      pin-dy: -1.1em,
      body-dy: -1em,
      offset-dy: -3em,
      fill: gray,
    )[#box(
        width: 11em,
        text(fill: gray)[Hey, since it's a url, it \ will start with `http`!],
      )]

    pinit-point-from(
      (3, 4),
      fill: gray,
    )[#box(
        width: 16em,
        text(
          fill: gray,
        )[But quickly sanity-check \ that it is not anything else...],
      )]
    v(4cm)
  }]
// #todo[#box(height: 10cm)[diagram of the URL starting with https:// example]]

#todo[Better examples. Show one example where you know because of your problem it is a good idea to simplify the problem, showing before and after of a very tangled tree and an untangled one, but that that might not always work].

#todo[Show example of adding more constraints while keeping the same result. Maybe say that if some theorem has a counterexample, then it has to has an odd numbered counterexample, so you can reduce the search space to half. But also maybe the solver would have found an even result before.].

The question that arises is: *do stronger implementations make tactics redundant?* After all, if the implementation is very smart, it could basically guide itself in a way that is equivalent or better than what the user can provide.

A familiar example of this behavior are compilers: it is generally wiser for programmers to leave optimization to the compiler and hand-written assembly might be worse than compiled code, especially for larger programs. #todo[Maybe this would also be nicer with a diagram.]

// #colbreak(weak: true)

== The competitors

#table(
  stroke: none,
  columns: (1fr, 1fr),
  align: center + bottom,
  inset: (y: 0.6em, x: 0.0em),
  smallcaps[*Z3str3*], smallcaps[*Z3-noodler*],
  [Official, upstream \ Z3 solver], [SotA, winner \ of SMT-COMP],
  [*2017*], [*2024*],
  [Theory aware\ case-splitting], [Novel technique, #smallcaps[Stabilization]],
  todo[cute icon for z3str3], todo[cute icon for z3-noodler],
)

= Methodology

There are many datasets for SMT problems. There are not so many tactics. How to obtain them? We could...

#table(
  stroke: none,
  columns: (1fr, 1fr),
  inset: 0.8cm,
  [...use Z3's generic tactics, and see which works for which problem...],
  [...construct custom tactics for each problem, leveraging the solutions...],

  [...but it is a bad simulation of domain-specific knowledge],
  [...but it is hard to implement and time-consuming],

  todo[diagram of going tactic by tactic],
  todo[diagram of using the solution to construct custom tactic],
)

Since each has its pros and cons, we use both! There might be insightful differences.

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
    box(
      inset: (left: 1cm),
    )[Everything is packaged with Nix, so you can easily reproduce the testing environment with 100% accuracy.],
  )
]

= Results

#todo[]

#v(1fr)
// #bibliography("/references.bib")

