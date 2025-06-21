#import "/utils.typ": z3str3, z3-noodler
  #table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    inset: 5pt,
    table.cell(rowspan: 2, stroke: none)[],
    table.cell(colspan: 2)[*Mean speedup \ (% of problems/ms)*],
    table.cell(colspan: 2)[*Mean runtime increase \ (ms/problem)*],

    [Average], [Best case], [Average], [Best case],

    ..{
      let data = toml("./plots/summary.toml")
      let f = (it, digits: 3, stron: false) => {
        let t = [#calc.round(it, digits: digits)]
        t
        // if stron { strong(t) } else { t }
      }

      let pm = (
        (a, b),
        first_digits: 3,
        second_digits: 2,
        strong: false,
      ) => [$#f(a, digits: first_digits, stron: strong) plus.minus #f(b, digits: second_digits)$]
      let highlight = (impl, body) => table.cell(
        fill: impl.color.transparentize(70%),
        body,
      )

      (
        strong(text(fill: z3str3.color.darken(20%))[_#z3str3.display _]),
        highlight(z3str3)[#pm(data.runtime.z3str3.rel, strong: true)],
        [#pm(data.runtime_min.z3str3.rel)],
        highlight(z3str3)[#pm(
            data.runtime.z3str3.abs,
            first_digits: 1,
            second_digits: 0,
          )],
        [#pm(data.runtime_min.z3str3.abs, first_digits: 1, second_digits: 0)],

        strong(text(fill: z3-noodler.color.darken(20%))[_#z3-noodler.display _]),
        highlight(z3-noodler)[#pm(data.runtime.z3-noodler.rel)],
        [#pm(data.runtime_min.z3-noodler.rel)],
        highlight(z3-noodler)[#pm(
            data.runtime.z3-noodler.abs,
            first_digits: 1,
            second_digits: 0,
          )],
        [#pm(
            data.runtime_min.z3-noodler.abs,
            first_digits: 1,
            second_digits: 0,
          )],
      )
    }
  )
