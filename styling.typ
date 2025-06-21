#import "./utils.typ": todo, DEBUG
#import "@preview/wordometer:0.1.4": total-words

#let styling(it) = {
  let is-empty-page() = {
    let current-page = counter(page).get().first()
    let last-page = counter(page).final().first()

    current-page == 1 or current-page == last-page
  }

  set page(
    paper: "us-letter",
    margin: (
      top: 3.5cm,
      bottom: 4cm,
      x: 3.8cm,
    ),
    footer: align(
      center,
      context {
        if is-empty-page() {
          return
        }

        counter(page).display()
      },
    ),

    numbering: "1",
  )

  set page(
    // fill: oklch(100%, 5%, 40deg),
    header: [#text(fill: red)[*DEBUG MODE!*] #h(1fr) Word count: #total-words],
    margin: (
      left: 1cm,
      right: 6.6cm,
    )
  ) if DEBUG
  // set page(
  //   width: 500pt,
  //   height: 600pt,
  //   margin: 1cm,
  // ) if DEBUG
  
  show raw: set text(font: "IosevkaTerm NF")
  // LaTeX style
  // set text(
  //   font: "New Computer Modern",
  //   size: 10pt,
  // )

  // TODO: Re-enable if I don't have much space.
  // // Custom
  // set text(
  //   font: "Lora",
  //   size: 10pt,
  // )

  set par(
    first-line-indent: 1em,
    justify: true,
  )

  // NOTE: This is disabled because you can't "undo" show rules and I want
  // to have the in-text links clickable but not underlined.
  // 
  // Underline actual links
  // show link: it => if type(it.dest) == str {
  //   underline(it)
  // } else {
  //   it
  // }

  set math.equation(numbering: "1. ")
  set heading(numbering: "1.1.")

  // superscripts for tables
  show figure.where(kind: table): set figure.caption(position: top)
  set table(stroke: 0.2mm)

  // Make block quotes font size smaller
  // https://libraryguides.vu.edu.au/ieeereferencing/QuotesParaphrase
  show quote.where(block: true): it => {
    pad(x: 3em)[
      #text(size: 1em - 1pt)[#it.body]
    ]
  }

  it
}
