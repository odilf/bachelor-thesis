#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "/utils.typ": z3str3, z3-noodler

#let example = black.transparentize(50%)

#let workflow-diagram(tight: false, bg: white) = diagram(
  node-stroke: 0.5pt,
  node-inset: 0.6em,
  crossing-fill: bg,
  node(
    (-0.8, 1),
    [
      *Dataset* \
      `QF_S` \
      `QF_SLIA` \
      `QF_SNIA`
    ],
    shape: fletcher.shapes.rect,
    corner-radius: 2pt,
  ),
  edge(
    "-|>",
    label: align(center)[Solve \ _(high timeout)_],
    shift: (6mm, 30%),
    bend: 55deg,
  ),
  edge(
    // "l,d",
    "-->",
    label: align(
      center,
      text(fill: example)[Discard _unsat_ cases],
    ),
    vertices: ((-1, 1), (-1, 1.8)),
    label-pos: 1,
    label-side: left,
    stroke: example,
    bend: -50deg,
    floating: true,
  ),
  node(
    (0, 1),
    [
      *Model solution* \
      for each input

      #text(fill: example)[
        $X = "hello" \
        Y = "world" \
        dots.v$
      ]
    ],
    shape: fletcher.shapes.rect,
    corner-radius: 2pt,
  ),
  edge(
    "-|>",
    label: align(center)[Run @algorithm-domain-specific-constraints],
    shift: (6mm, 30%),
    bend: 40deg,
  ),
  node(
    (0.9, 1),
    [
      *Domain-specific \ constraints*

      #text(fill: example)[
        $"end"(X) = #[llo] \
        |Y| < 10 \
        dots.v$
      ]
    ],
    shape: fletcher.shapes.rect,
    corner-radius: 2pt,
  ),
  edge(
    "-|>",
    label: align(center)[Benchmark \ _(normal timeout)_],
    label-fill: false,
    stroke: 1pt,
    shift: (9mm, 15mm),
    bend: 57deg,
    floating: true,
  ),
  node(
    (2 - 0.15, 1),
    [
      *Benchmark results* \

      #{
        set text(fill: example)
        table(
          columns: (auto, auto, auto),
          stroke: 0.5pt + example,
          [`ms`], [`help`], [`impl`],
          [82.4], [0], [#z3str3.display],
          [49.8], [0.5], [#z3str3.display],
          [18.2], [0], [#z3-noodler.display],
          [15.1], [0.5], [#z3-noodler.display],
        )
      }

      #if not tight {
        set text(size: 1em - 6pt)
        [(Multiple iterations for each)]
      }
    ],
    shape: fletcher.shapes.rect,
    corner-radius: 2pt,
    inset: 9pt,
  ),
  edge(
    "d",
    "-->",
    label: text(fill: example)[Statistical analysis],
    label-side: center,
    stroke: example,
  ),
)
