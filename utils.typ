// #import "@preview/drafting:0.2.2": *
#import "/deps/typst-drafting/drafting.typ": *

// Can only pass strings with `--input`
#let DEBUG = sys.inputs.at(default: "true", "DEBUG") != "false"

/// Use if something is not done yet.
//
// Setting `--input DEBUG=false` makes the TODOs disappear.
#let todo = body => if DEBUG {
  let red = oklch(60%, 30%, 30deg)
  set text(font: "scientifica", size: 8pt)
  // [#highlight(fill: red)[*TODO #sym.forces* #body <todo-body>] <ignore-word-count>]
  // text(weight: "light", style: "italic", highlight(fill: red)[#body <todo-body> <ignore-word-count>])
  margin-note(link: "index", stroke: red)[#body <ignore-word-count>]
  // lorem(50)
  // text(fill: red.darken(30%), super[[1]])
} else { }

#let impls = (
  (name: "z3str3", display: smallcaps[Z3str3], year: 2017),
  (name: "z3-noodler", display: smallcaps[Z3-Noodler], year: 2024),
)

#let z3str3 = impls.at(0)
#let z3-noodler = impls.at(1)

#let url-link(dest, body) = {
  link(dest, body)
  footnote(underline(dest))
}
