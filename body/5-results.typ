#import "/utils.typ": todo, z3str3, z3-noodler
#import calc.round;

#let data = toml("/assets/plots/summary.toml")
#let f((mu, std)) = {
  let mu = $#round(mu, digits: 3)$
  let std = round(std, digits: 2)

  $bold(mu) plus.minus std$
}

= Findings

We calculated the (geometric) mean of the speedup of the average runtime to solve a problem with vs without help. We also weighed the mean by the runtime to solve the problem without help, to be more representative of performance in practice (since speedups in bigger cases are more relevant). We show both the weighted and unweighted mean in @table-summary.

#let highlight = (impl, body) => table.cell(
  fill: impl.color.transparentize(70%),
  body,
)

#figure(
  table(
    columns: (auto, auto, auto),
    inset: (x: 10pt, y: 6pt),
    align: center,
    table.cell(stroke: none)[],
    [Mean speedup \ (weighted)],
    [Mean speedup \ (unweighted)],

    strong(text(fill: z3str3.color.darken(20%))[_#z3str3.display _]),
    highlight(z3str3)[#f(data.runtime.z3str3.rel_weighted)],
    [#f(data.runtime.z3str3.rel)],

    strong(text(fill: z3-noodler.color.darken(40%))[_#z3-noodler.display _]),
    highlight(z3-noodler)[#f(data.runtime.z3-noodler.rel_weighted)],
    [#f(data.runtime.z3-noodler.rel)],
  ),
  caption: [Mean speedups of average runtime with vs without help, \ weighted by the original runtime (without help) and equally.]
) <table-summary>

// - *#z3str3.display*: speedup of #f(data.runtime.z3str3.rel_weighted)
// - *#z3-noodler.display*: speedup of #f(data.runtime.z3-noodler.rel_weighted)

The results are damning: #z3-noodler.display sees _significantly_ less performance improvement than #z3str3.display when given domain-specific guidance in the form of search space reduction.

In the rest of the section we explain in more detail the two primary reasons we see these results; namely, the *inherent slowdowns* of #z3-noodler.display and the sense in which it is *too good to improve*. Finally, we briefly discuss the validity of the findings, and the fact that the dataset has some skew does not alter the main takeaways of this paper.

// This is mainly because of two reasons, namely, that #z3-noodler.display displays more cases where the additional constraints are counterproductive and that #z3str3.display takes longer to solve problems, giving it more opportunity to see performance improvements. We explain these points in detail shortly. Another observation from @table-summary is that the unweighted mean speedup for #z3str3.display is negative, which might be surprising. However, this is because #todo[]

== Inherent slowdowns

There are some cases where the additional constraints that reduce the search space actively harmed performance. This happened more often with #z3-noodler.display. We show the runtime differences on @fig-new-vs-original, where the upper red zone indicates slowdowns. #z3-noodler.display, on the right, has a vertical line at around 1ms of original time and, in general, we see #z3-noodler.display going a lot further and more consistently into the red (i.e., slowdown) region. This is also reflected in the mean difference in runtime, which is, in fact, positive on average for #z3-noodler.display (i.e., problems took longer to run).

#figure(
  image(
    width: 130%,
    "/assets/plots/new-vs-original-heatmaps.svg",
  ),
  caption: [Heatmap comparison of runtime with and without help. Shaded area indicates slowdowns, diagonal line corresponds to no change in performance. $mu_"diff"$ is the mean of the difference of the runtimes.],
) <fig-new-vs-original>

To highlight one particular example where a constraint has surprising results, the problem `QF_S/20230329-automatark-lu/instance05943.smt2` has solution $X = #quote[`000-\ddddd-\ddddd-\ddd\u{a}`]$ (where `\d` is not an escape sequence, it is a literal backslash followed by a "`d`"), which Z3 finds instantly. The solution is 23 characters long and clearly contains many "`d`" characters. Logically, adding either a constraint that the length is less than 24 or that the solution contains a "`d`" doesn't really impact performance. However, if one adds both constraints, Z3 timeouts. That is, adding two reasonable constraints collapses the solver, but adding either independently doesn't. We haven't investigated the underlying cause, but it goes to show that the performance impact of adding constraints can be very unpredictable.

== Too fast to improve

The second reason why #z3-noodler.display sees less improvement than #z3str3.display is because there is more speedup the bigger a test case is, and, conversely, the additional constraints end up adding mostly overhead to small, fast cases. The truth of the matter is, then, that #z3-noodler.display is so efficient that it rarely reaches high runtimes.

We can see clearly how the speedup increases in @fig-mean-speedup-vs-original-linear. There is a lot of noise at the start but there is a clear trend upwards for #z3str3.display. For #z3-noodler.display, all datapoints are clumped closed to zero so we can't observe any trend. This is unfortunate but, it does reflect what would happen in practice; that is, that #z3-noodler.display has less of a chance to get help from one's guidance, since the runs end a lot faster.

#figure(
  image(width: 130%, "/assets/plots/speedup-vs-original-linear.svg"),
  caption: [Speedup vs original time. Shaded area indicates slowdown. \ (density at the start not accurately represented)],
) <fig-mean-speedup-vs-original-linear>

== Why is 

One final observation manifests when looking at the distribution of speedups, which we show on @fig-histograms-separate. Namely, we see that the (geometric) mean of the speedups is less than one for both implementations, but that it is approximately three times worse for #z3-noodler.display. It might be surprising that #z3str3.display sees a slowdown of about $15%$ on average, but this is because the small, fast cases are overrepresented in the dataset. As we saw with @fig-mean-speedup-vs-original-linear, #z3str3.display does eventually see consistent significant speedups, and that the mean runtime difference is negative (i.e., faster) as expected.

#figure(
  image(width: 130%, "/assets/plots/histograms-separate.svg"),
  caption: todo[],
) <fig-histograms-separate>

To be clear, these results are not only because #z3-noodler.display completes faster. Across basically every range, #z3-noodler.display is slowed down significantly more than #z3str3.display. For instance, between 1-100ms the speedup is #f(data.runtime.z3str3.rel_1-100) for #z3str3.display vs #f(data.runtime.z3-noodler.rel_1-100) for #z3-noodler.display; and even for *less than 1ms* the speedups are #f(data.runtime.z3str3.rel_sub1ms) for #z3str3.display vs #f(data.runtime.z3-noodler.rel_sub1ms) for #z3-noodler.display

This strongly indicates again that #z3-noodler.display being fast is not the _only_ reason why the speedup is worse, and that seemingly harmless (or even seemingly helpful!) constraints harm performance more than for #z3str3.display.

// The fact that the overhead takes over in small cases also illuminates one additional observation: the fact that #z3str3.display is slowed down by 13% (shown in the header of @fig-new-vs-original). This seems counterintuitive, but it is due to the fact that the dataset used overrepresents these small cases.
































// == Old versions ==

// We have found that

// In @fig-new-vs-original we compare the original runtime vs the runtime with help (both in logarithmic scales); and in @table-summary indicate the most important statistics, including the (geometric @flemingHowNotLie1986) mean of the speedup over each problem when using domain-specific help, and the (arithmetic) mean increase in runtime for the average and the best case.

// #figure(
//   image(
//     width: 130%,
//     "/assets/plots/new-vs-original-heatmaps.svg",
//   ),
//   caption: [Heatmap comparison of runtime with and without help. Shaded area indicates slowdowns, diagonal line corresponds to no change in performance.],
// ) <fig-new-vs-original>

// A general summary of the data is given in @fig-absolute-relative-hist, as pairs of relative "speedup"s and absolute differences. Note that each speedup and difference is the mean speedup/difference #todo[Dennis says mean has to be geometric, not sure why.] of every problem that has been benched with both amounts of helps, not the speedup/difference of the mean. This is to make sure there is a 1-1 correspondence, and that the results are not because, for example, some particularly hard problem wasn't benchmarked with one and was with the other. #todo[Explain how exactly speedup is calculated]
// #todo[explain more why we don't have exactly the same benchmark data for all of them.]

// #figure(
// include("/assets/summary.typ"),
//   caption: [Summary of results. For each implementation, mean speedup of the average case and best case on the right, mean runtime increase of the average and best case on the left. Important results are highlighted and color-coded.],
// ) <table-summary>

// There are a few things to note about these results. First and foremost, it seems that providing help is detrimental to both #z3str3.display and #z3-noodler.display, slowing them down by about 13% and 71% respectively. However, for #z3str3.display, it took 3ms less on average to solve the problems, which indicates that the slowdowns come from small, fast cases, but that otherwise there is a speedup. We can see this more clearly in @fig-mean-speedup-vs-original-with-range, where the mean speedup is shown for various ranges of (original) runtimes, along with their min and max speedup.

// #figure(
//   image("/assets/plots/mean-speedup-vs-original-time-with-range.svg"),
//   caption: [Mean speedup vs original time. Dots represent average speedup over the corresponding ranges, and whiskers the minimum and maximum over said range. Shaded area indicates slowdown.],
// ) <fig-mean-speedup-vs-original-with-range>
// #figure(
//   image(width: 130%, "/assets/plots/speedup-vs-original-linear.svg"),
//   caption: [Mean speedup vs original time. Dots represent average speedup over the corresponding ranges, and whiskers the minimum and maximum over said range. Shaded area indicates slowdown.],
// ) <fig-mean-speedup-vs-original-with-range>

// In @fig-mean-speedup-vs-original-with-range we see that, indeed, the speedup seems to increase as the original time increases.

// This plot illuminates something clearly: #z3-noodler.display sees little improvement



// The results are damming: constraining the search space for #z3str3.display increased performance on average by 18.5%, while doing the same on #z3-noodler.display it _decreased_ performance by more than 80% on average. This already tells us that applying optimizations that are sensible on the abstract (such as reducing the search space) are not necessarily going to reflect on performance improvements in practice.

// There are a few other things to note about these results. Namely:
// 1. The average runtime is larger across the board.
// 2. The best case is, overall, slowed down on _both_ implementations.
// 3. The deviations are very big

// The mean increase in runtime implies that at least some large cases are slower. For instance, if a case $a$ is slowed down up by 10% and a case $b$ is sped down by 5% but case $b$ originally took 30s while case $a$ only 20ms then, overall, the _speedup_ is negative (about 2%) but it took less time to run (by about 1.7 seconds).

// To take a more hollistic view at the data, we can use @fig-absolute-relative-hist, that shows histograms of the speedups and the runtime increases. In particular, since we have multiple iterations per problem, the top row uses the average of all iterations as the representative value for a problem, while the bottom row uses the minimum (i.e., the best case).

// All standard deviations are quite large, so in @fig-absolute-relative-hist we show histogram of the

// We see that for #z3str3.display, we double its performance on average; while on #z3-noodler.display, we only increase it by 33%. That does support our hypothesis: the stronger implementation, #z3-noodler.display, was less affected by the domain-specific help than the simpler one. But of course, there is more to the story #todo[too informal?]. Something that definitely needs to be addressed is the fact that the standard deviation is about five times larger than the speedup, i.e., there is clearly a lot of spread in the data. A more comprehensive view, using histograms, is shown in @fig-absolute-relative-hist.

// #figure(
//   image(
//     width: 130%,
//     "/assets/plots/absolute-diff-relative-speedup-histograms-all-columns.svg",
//   ),
//   caption: [Speedup and runtime differences. On the left the plotted values are the ratio of the value without help over the value with help (i.e., the speedup ratio); on the right, the difference between the value without help minus the value with help. Red region indicates slowdown.
//   ],
// ) <fig-absolute-relative-hist>

// It is important to note that @fig-absolute-relative-hist's $y$ axis is logarithmic, so a very big majority of the values are concentrated around $1$, which means that for most problems, the runtime with and without the help was about the same.

// We also see values with a "speedup" lower than 1, which it means it is in fact a _slowdown_. In other words, for many problems using help was detrimental. A reasonable explanation for the slowdowns is that the simple cases (e.g., where the solution is one single character string) are already very fast and the extra constraints just add overhead to the solver. To visualize the results in this dimension, we can plot a heatmap of the speedup compared to the original runtime, as shown in @fig-speedup-vs-original.

// #figure(
//   image("/assets/plots/speedup-vs-original-heatmaps.png"),
//   caption: [Speedup vs original time #todo[explain properly]],
// ) <fig-speedup-vs-original>


// The figure shows the distribution of the speedups for every initial runtime. It is not immediately clear that the performance improvement is better for larger original runtimes. In fact, we see that there are consistent slowdowns over most of the dataset.

// To be more precise, we can plot the mean speedup of each original runtime bin. This is shown in @fig-mean-speedup-vs-original, which in essence is taking every "column" from @fig-speedup-vs-original and calculating its mean. Here we see that indeed, the mean speedup is lowest for the very fast cases at the start. For #z3str3.display we see un upward trend, where the speedup seems to increase the longer the test case is.

// #figure(
//   image("/assets/plots/mean-speedup-vs-original-time.svg"),
//   caption: [Mean speedup vs original time #todo[explain properly]],
// ) <fig-mean-speedup-vs-original>

// However, it is important to note again that @fig-mean-speedup-vs-original is a variation of @fig-speedup-vs-original and the data is just as indeterminate. In @fig-mean-speedup-vs-original-error-bars we show @fig-mean-speedup-vs-original with the standard deviation for each bin, which shows that performance improvement is pretty unpredictable.


// In fact, one of the main points that can be taken away from this experiment is that _predicting performance is hard_ #todo[I feel I can find a citation for this (as in, I feel I've heard this before).]. Even in the "straightforward" case of #z3str3.display we see that the results can be surprising. The somewhat sad realization is, then, that reducing the search space of a problem is an unreliable way to get better performance.

// The result that is much more consistent though is that the stronger implementation, #z3-noodler.display, shows less speedup than #z3str3.display. The precise difference is captured by @table-summary but, on average, domain-specific guidance tends to be a third as effective in #z3-noodler.display than #z3str3.display.


