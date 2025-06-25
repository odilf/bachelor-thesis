#import "@preview/frame-it:1.2.0": *
#import "/utils.typ": z3str3, z3-noodler


// #let note-color = color.oklch(70%, 15%, 130deg)

// #let (note,) = frames(
//   note: ("Note", z3str3.color.darken(10%).transparentize(63%)),
// )


#let left =  z3str3.color.darken(10%).transparentize(63%);
#let right =  z3-noodler.color.darken(10%).transparentize(63%);

#let note = frame("Note", left)

#show: frame-style(styles.boxy)

#let setup() = {
  show: frame-style(styles.boxy)
  note(arg: left)[*Environment reproducibility*][
    #grid(
      columns: (47mm, auto),
      gutter: 5mm,
      align(
        horizon,
        image(
          // width: auto,
          // height: 42mm,
          "/assets/nix-logo.svg",
        ),
      ),
      [
        Thanks to Nix, you can easily reproduce the testing environment with 100% accuracy.],
    )
  ]
}

#let running() = {
  show: frame-style(styles.boxy)
  note(arg: right)[*Machine configuration*][
    Programs were ran on an laptop with a M1 Max CPU with 8GB of RAM with no user programs running. Each combination was benchmarked multiple times.
    // #grid(
    //   columns: (5cm, auto),
    //   gutter: 5mm,
    //   align(
    //     horizon,
    //     []
    //     // image(
    //     //   width: auto,
    //     //   "/assets/nix-logo.svg",
    //     // ),
    //   ),
    //   [
    //     Thanks to Nix, you can easily reproduce the testing environment with 100% accuracy.],
    // )
  ]
}
