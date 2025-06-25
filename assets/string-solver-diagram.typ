
#import "@preview/fletcher:0.5.8" as fletcher: (
  diagram,
  node,
  edge,
  cetz,
  draw-diagram,
)
#import "/utils.typ": z3str3, z3-noodler

#let example = black.transparentize(50%)

#let bad = oklch(40%, 50%, 10deg)
#let good = oklch(60%, 60%, 150deg)
#let stroke = 0.3mm;

#diagram(
  spacing: (5mm, 1mm),
  node-inset: 1mm,

  node(
    (2, 0),
    name: "initial-constraints",
    enclose: (
      (0, 0),
      (0, 1),
      (0, 2),
      (0, 3),
    ),
    stroke: stroke,
    snap: -1,
  ),
  node(
    (0, -1),
    [*Initial constraints*],
    inset: 3mm,
  ),
  node(
    (0, 0),
    $(X plus.double Y) "startsWith" #quote[hello]$,
  ),
  node(
    (0, 1),
    $(Y plus.double Z) "endsWith" #quote[world]$,
  ),
  node(
    (0, 2),
    align(center)[$Y "contains" #quote[-]$],
    width: 4.8cm,
    // align: right,
  ),
  node(
    (0, 3),
    $(|X| < 2) and (|Y| < 9) and (|Z| < 3)$,
  ),

  node(
    (2, 0),
    name: "lia-equations",
    enclose: (
      (1, 0),
      (1, 1),
      (1, 2),
    ),
    stroke: stroke,
    snap: -1,
    width: 2.9cm,
  ),
  node(
    (1, -1),
    [*LIA equations*],
  ),
  edge((0, 0), (1, 0), "=>", "crossing"),
  node(
    (1, 0),
    $|X| + |Y| >= 5$,
  ),
  edge((0, 1), (1, 1), "=>", "crossing"),
  node(
    (1, 1),
    $|Y| + |Z| >= 5$,
  ),
  edge((0, 2), (1, 2), "=>", "crossing"),
  node(
    (1, 2),
    $|Y| >= 1$,
  ),

  // edge((-1, 7), (3, 7), "--", stroke: 1pt),
  edge(
    (-0.6, 9),
    (0, 14),
    "->",
    bend: -20deg,
    label-side: center,
    stroke: stroke,
  ),
  edge(
    (-0.6, 9),
    (0, 18),
    "->",
    bend: -60deg,
    label: [Constraint \ propagation \ (according to \ LIA eqs.)],
    floating: true,
    stroke: stroke,
  ),

  edge((0.3, 14), (1, 14), "=>", stroke: bad + stroke),
  node((0, 14), [$|X| = 0$]),
  node(
    (1, 14),
    text(fill: bad)[
      $|Y| >= 5$ \
      $X = #quote[]$ \
      $Y = #quote[hello-wo]$ \
      $Z = #quote[rld]$
    ],
  ),
  edge((0.4, 3.3), (2, 14), "<|-", "crossing", bend: 25deg, stroke: bad + stroke),
  node(
    (2, 14),
    text(fill: bad)[#sym.crossmark infeasible \ because $|Z| >= 3$],
  ),

  edge((0.3, 18), (0.65, 18), "=>", stroke: stroke),
  node((0, 18), $|X| = 1$),
  node(
    (1, 18),
    [
      $X = #quote[h]$ \
      $Y = #quote[ello-wor]$ \
      $Z = #quote[ld]$
    ],
  ),
  // node((1, 20), $X = #quote[h]$),
  // node((1, 21), $Y = #quote[ello-wor]$),
  // node((1, 22), $Z = #quote[ld]$),
  node((2, 18), text(fill: good)[#sym.checkmark all good \ found solution!]),
  render: (grid, nodes, edges, options) => {
    cetz.canvas({
      cetz.decorations.flat-brace(
        (10, 4.84),
        (0, 4.84),
        // content-offset: 0.3,
        stroke: stroke,
        aspect: 86.6%,
      )
      draw-diagram(grid, nodes, edges, debug: options.debug)
    })
  },
)
