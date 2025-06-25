// #import "@preview/drafting:0.2.2": *
#import "/deps/typst-drafting/drafting.typ": *

/// Debug mode, but more tidy.
#let TIDY-DEBUG = false;

// Can only pass strings with `--input`
#let DEBUG = false
// #let DEBUG = (
//   not TIDY-DEBUG and sys.inputs.at(default: "true", "DEBUG") != "false"
// )
#let REDACTED = false
#let sensitive = it => if REDACTED { highlight(fill: black, it) } else { it }

/// Use if something is not done yet.
//
// Setting `--input DEBUG=false` makes the TODOs disappear.
#let todo = body => {
  // panic(body) // To check if there are any TODOs left.
  let red = oklch(60%, 30%, 30deg)
  if DEBUG {
    set text(size: 8pt)
    margin-note(link: "index", stroke: red)[#body <ignore-word-count>]
  } else if TIDY-DEBUG {
    text(fill: red, [*#sym.dagger*])
  }
}


#let z3str3 = (
  // display: text(fill: oklch(70%, 90.54%, 170deg).darken(60%), smallcaps[Z3str3]),
  display: smallcaps[Z3str3],
  color: oklch(70%, 90.54%, 170deg),
  year: 2017,
)
#let z3-noodler = (
  // display: text(fill: oklch(70%, 90%, 290deg).darken(90%), smallcaps[Z3-Noodler]),
  display: smallcaps[Z3-Noodler],
  color: oklch(70%, 90%, 290deg),
  year: 2024,
)

#let impls = (
  z3str3,
  z3-noodler,
)

// #panic(impls.map(impl => impl.color.rgb()))

/// A url that puts the link in the footnote, for "print".
#let url-link(dest, body) = {
  link(dest, body)
  footnote(underline(dest))
}


#let domain-specific-constraints = (
  (
    "length-greater-than": (
      symbol: sym.gt,
    ),
    "length-less-than": (
      symbol: sym.lt,
    ),
    "length-equal": (
      symbol: sym.eq,
    ),
    "starts-with": (
      symbol: sym.tack.r,
    ),
    "ends-with": (
      symbol: sym.tack.l,
    ),
    "contains": (
      symbol: sym.tack.b,
    ),
  )
    .values()
    .map(symbol => (
      symbol: symbol,
      help-sym: $h^(symbol)$,
    ))
)

#let info = (
  author: sensitive[Odysseas Machairas],
  responsible-prof: sensitive[Soham Chakraborty],
  supervisor: sensitive[Dennis Sprokholt],
  examiner: sensitive[Andy Zaidman],
  title: [Is solver guidance redundant for strong SMT implementations?],
  subtitle: [An exploration of domain-specific vs general \ improvements applied to Z3's string theories.],
)

#let constraints = (
  (
    name: [Length greater than],
    help: $ h^>= = (lambda ell) / ln(p_s) $,
    parameter: $ ell = (h^>= ln(p_s)) / lambda $,
  ),
  (
    name: [Length less than],
    help: $ h^< = ln(1 - e^(-lambda ell)) / ln(p_s) $,
    parameter: $ ell &= ln(1 - e^(h^<) p_s) / (-lambda) $,
  ),

  (name: [Length equals], help: $ ln(p_ell) / ln(p_s) $, parameter: $ "None" $),
  (
    name: [Prefix (starts with)],
    help: $ h^(tack.r) = |partial s| (ln(C) + lambda) / (-ln(p_s)) $,
    parameter: $ |partial s| &= h^(tack.r) (-ln(p_s)) / (ln(C) + lambda) $,
  ),
  (
    name: [Suffix (ends with)],
    help: $ h^(tack.l) = |partial s| (ln(C) + lambda) / (-ln(p_s)) $,
    equation: $ |partial s| &= h^(tack.l) (-ln(p_s)) / (ln(C) + lambda) $,
  ),
  (
    name: [Substring (contains)],
    help: $
      h^(tack.t) = (|partial s| ln(C) - ln(|s| - |partial s| + 1)) / (-ln(p_s))
    $,
    parameter: [Transcedental eq, \ find by binary search],
  ),
)

#let cite-wrong(..labels) = for label in labels.pos() {
    cite(label, style: "council-of-science-editors")
}
