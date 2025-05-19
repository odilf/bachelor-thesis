#import "/utils.typ": todo, z3str3, z3-noodler

= Results and discussion <results>



A general summary of the data is given in @fig-absolute-relative-hist, as pairs of relative "speedup"s and absolute differences.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: center,
    table.cell(rowspan: 2)[],
    table.cell(colspan: 2)[Relative speedup],
    table.cell(colspan: 2)[Absolute difference],
    [#z3str3.display],
    [#z3-noodler.display],
    [#z3str3.display],
    [#z3-noodler.display],
    ..toml("/assets/plots/summary.toml")
      .pairs()
      .map(((column, values)) => {
        let f = it => calc.round(it, digits: 3)
        let rest = values
          .values()
          .map(((mean, std)) => [#f(mean) $plus.minus$ #f(std)])
        (column, ..rest)
      })
      .flatten(),
  ),
  caption: [Summary of results #todo[write good caption]],
) <table-summary>

We see that for #z3str3.display, we double its performance on average; while on #z3-noodler.display, we only increase it by 33%. That does support our hypothesis: the stronger implementation, #z3-noodler.display, was less affected by the domain-specific help than the simpler one. But of course, there is more to the story #todo[too informal]. Something that definitely needs to be addressed is the fact that the standard deviation is about five times larger than the speedup, i.e., there is clearly a lot of spread in the data. A more comprehensive view, using histograms, is shown in @fig-absolute-relative-hist.

#figure(
  image("/assets/plots/absolute-diff-relative-speedup-histograms-all-columns.svg"),
  caption: [Relative and absolute differences in runtime, z3_time, memory usage and number of decisions. On the left the plotted values are the ratio of the value without help over the value with help (i.e., the speedup ratio, for runtime); on the right, the difference between the value without help minus the value with help.
  ],
) <fig-absolute-relative-hist>

It is important to note that @fig-absolute-relative-hist's $y$ axis is logarithmic, so a very big majority of the values are concentrated around $1$, which means that for most problems, the runtime with and without the help was about the same. We also see values with a "speedup" lower than 1, which it means it is in fact a _slowdown_. In other words, for many problems using help was detrimental. Why could this be? #todo[Is this appropriate?]

A reasonable explanation for the slowdowns is that the simple cases (e.g., where the solution is one single character string) are already very fast and the extra constraints just add overhead to the solver. To visualize the results in this dimension, we can plot a heatmap of the speedup compared to the original runtime, as shown in @fig-speedup-vs-original.

#figure(
  image("/assets/plots/speedup-vs-original-heatmaps.png"),
  caption: [Speedup vs original time #todo[explain properly]],
) <fig-speedup-vs-original>

The figure shows the distribution of the speedups for every initial runtime. It is not immediately clear that the performance improvement is better for larger original runtimes. In fact, we see that there are consistent slowdowns over most of the dataset.

To be more precise, we can plot the mean speedup of each original runtime bin. This is shown in @fig-mean-speedup-vs-original, which in essence is taking every "column" from @fig-speedup-vs-original and calculating its mean. Here we see that indeed, the mean speedup is lowest for the very fast cases at the start. For #z3str3.display we see un upward trend, where the speedup seems to increase the longer the test case is.

#figure(
  image("/assets/plots/mean-speedup-vs-original-time.svg"),
  caption: [Mean speedup vs original time #todo[explain properly]],
) <fig-mean-speedup-vs-original>

However, it is important to note again that @fig-mean-speedup-vs-original is a variation of @fig-speedup-vs-original and the data is just as indeterminate. In @fig-mean-speedup-vs-original-error-bars we show @fig-mean-speedup-vs-original with the standard deviation for each bin, which shows that performance improvement is somewhat unpredictable.

#figure(
  image("/assets/plots/mean-speedup-vs-original-time-error-bars.svg"),
  caption: [Mean speedup vs original time #todo[explain properly]],
) <fig-mean-speedup-vs-original-error-bars>

In fact, something value that can be taken away from this experiment is that _predicting performance is hard_ #todo[I feel I can find a citation for this.]. Even in the "straightforward" case of #z3str3.display we see that the results can be surpising. The somewhat sad realization is, then, that reducing the search space of a problem is an unreliable way to get better performance.

The result that is much more consistent though is that the stronger implementation, #z3-noodler.display, shows less speedup than #z3str3.display. The precise difference is captured by @table-summary but, on average, domain-specific guidance tends to be a third as effective in #z3-noodler.display than #z3str3.display.
