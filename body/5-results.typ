#import "/utils.typ": todo, z3str3, z3-noodler
#import calc.round;

#let data = toml("/assets/plots/summary.toml")
#let f((mu, std)) = {
  let mu = $#round(mu, digits: 3)$
  let std = round(std, digits: 2)

  $bold(mu) plus.minus std$
}

= Results and discussion

The principal statistic from the experiments is the geometric mean of the speedup of the average runtime to solve a problem with vs without help. We weigh the mean by the original runtime (i.e., without help), which is more representative of performance in practice (since speedups in bigger cases are more relevant). We show both the weighted and unweighted mean in @table-summary.


#figure(
  {
    set table(inset: (x: 10pt, y: 6pt))
    include "/assets/summary.typ"
  },
  caption: [Mean speedups of average runtime with vs without help, \ weighted by the original runtime (without help) and equally.]
) <table-summary>

The results are clear: #z3-noodler.display sees _significantly_ less performance improvement than #z3str3.display when given domain-specific guidance in the form of search space reduction.

In the rest of the section we explain in more detail the two primary reasons we see these results; namely, the *inherent slowdowns* of #z3-noodler.display and the sense in which it is *too good to improve*.

== Inherent slowdowns

There are some cases where the additional constraints that reduce the search space actively harmed performance. This happened more often with #z3-noodler.display. We show the runtime differences on @fig-new-vs-original, where the upper red zone indicates slowdowns. #z3-noodler.display, on the right, has a vertical line at around 1ms of original time and, in general, we see #z3-noodler.display going a lot further and more consistently into the red (i.e., slowdown) region. This is also reflected in the mean difference in runtime, which is, in fact, positive on average for #z3-noodler.display (i.e., problems took longer to run).

#figure(
  image(
    width: 100%,
    "/assets/plots/new-vs-original-heatmaps.svg",
  ),
  caption: [Heatmap comparison of runtime with and without help. Shaded area indicates slowdowns, diagonal line corresponds to no change in performance. $mu_"diff"$ is the mean of the difference of the runtimes.],
) <fig-new-vs-original>

To highlight one particular example where a constraint has surprising consequences, instance 5942 of dataset "automatark-lu" has solution $X = #quote[`000-\ddddd-\ddddd-\ddd⤶`]$, which Z3 finds instantly. The solution is 23 characters long and clearly contains many "`d`" characters. Logically, adding either a constraint that the length is less than 24 or that the solution contains a "`d`" does not really impact performance. However, if one adds both constraints, Z3 timeouts. That is, adding two reasonable constraints collapses the solver, but adding either independently does not. We have not investigated the underlying cause, but it goes to show that the performance impact of adding constraints can be very unpredictable.

== Too fast to improve

The second reason why #z3-noodler.display sees less improvement than #z3str3.display is because there is more speedup the bigger a test case is, and, conversely, the additional constraints end up adding mostly overhead to small, fast cases. The truth of the matter is, then, that #z3-noodler.display is so efficient that it rarely reaches high runtimes.

We can see clearly how the speedup increases in @fig-mean-speedup-vs-original-linear. There is a lot of noise at the start but there is a clear trend upwards for #z3str3.display. For #z3-noodler.display, all datapoints are clumped closed to zero so we cannot observe any trend. This is unfortunate, but it does reflect what would happen in practice; that is, that #z3-noodler.display has less of a chance to get help from one's guidance, since the runs end a lot faster.

#figure(
  image(width: 100%, "/assets/plots/speedup-vs-original-linear.svg"),
  caption: [Speedup vs original time for #z3str3.display and #z3-noodler.display. Shaded area indicates slowdown. \ (density at the start not accurately represented)],
) <fig-mean-speedup-vs-original-linear>

But, to be clear, the overall slowdown is not _only_ because #z3-noodler.display completes faster. Across basically every range, #z3-noodler.display is slowed down significantly more than #z3str3.display. For instance, between 1-100ms the speedup is #f(data.runtime.z3str3.rel_1-100) for #z3str3.display vs #f(data.runtime.z3-noodler.rel_1-100) for #z3-noodler.display; and even in the range 0-1ms, the speedups are #f(data.runtime.z3str3.rel_sub1ms) for #z3str3.display vs #f(data.runtime.z3-noodler.rel_sub1ms) for #z3-noodler.display. This happens across almost all ranges, which strongly indicates, again, that #z3-noodler.display being fast is not singlehandedly the reason why the speedup is worse, and that seemingly harmless (or even seemingly helpful) constraints genuinely do more relative harm to performance in #z3-noodler.display than #z3str3.display.
