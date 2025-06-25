#import "@preview/frame-it:1.1.2": *
#import "/utils.typ": z3str3


// #let note-color = color.oklch(70%, 15%, 130deg)

#let (note,) = frames(
  note: ("Reproducibility note", z3str3.color.transparentize(70%)),
)
#show: frame-style(styles.boxy)

#let setup() = note[*Setup*][
  #grid(
    columns: (5cm, auto),
    gutter: 5mm,

    align(
      horizon,
      image(
        width: auto,
        "/assets/nix-logo.svg",
      ),
    ),
    [
      Thanks to Nix, you can easily reproduce the testing environment with 100% accuracy.],
  )
]

#let running() = note[*Running*][
  #grid(
    columns: (5cm, auto),
    gutter: 5mm,

    align(
      horizon,
      image(
        width: auto,
        "/assets/nix-logo.svg",
      ),
    ),
    [
      Thanks to Nix, you can easily reproduce the testing environment with 100% accuracy.],
  )
]
