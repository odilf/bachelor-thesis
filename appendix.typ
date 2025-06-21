#set heading(numbering: "A.1.", supplement: "Appendix")

#text(size: 32pt)[*Appendix*]

= Derivations of help quantification <appendix-derivations>

To carry out the mathematical derivation of exactly how much help each constraint needs (as shown in @table-constraint-parameters-help), we first define the guesser with more rigor. Namely, we say that the length $L$ of the guessed string follows an exponential distribution with parameter $lambda$ such that $L tilde "Exp"(lambda)$ with probability density function $f(x) = lambda e^(-lambda x)$. The chance of, given a solution $s$, guessing the correct string length is

$
  p_(ell) &= P(|s| <= L < |s| + 1) \
  &= integral_(|s|)^(|s| + 1) f(x) d x \
  &= e^(-lambda|s|) - e^(-lambda (|s| + 1)) \
  &= e^(-lambda|s|) (1 - e^(-lambda))
$

and

$
  ln(p_ell) &= ln(e^(-lambda|s|) (1 - e^(-lambda))) \
  &= ln(e^(-lambda|s|)) + ln((1 - e^(-lambda))) \
  &= -lambda|s| + ln(1 - e^(-lambda))
  // &= (-lambda |s| ) / (-lambda (|s| + 1)) = (|s|) / (|s| + 1)
$

// It will be useful later to know that

// $ 1 / ln(p_ell) = (|s| + 1) / (|s|) = 1 + 1 / (|s|) $

The probability of guessing the correct characters given the length is just $p_c = C^(-|s|)$ so $ln(p_c) = -|s| ln(C)$, where $C$ is the number of distinct characters you can choose. The probability of guessing a solution $s$ is then $p_s = p_c dot p_(ell)$ and so
$
  ln(p_s)
  &= ln(p_c) + ln(p_(ell)) \
  &= -|s| ln(C) -lambda|s| + ln(1 - e^(-lambda))
$ <eq-ln-ps>.

Help is defined as

$
  h^* &= - ln(p^* / p) / ln(p) \
  &= (ln(p^*) - ln(p)) / (-ln(p)) \
$

== Value for $lambda$ that maximizes $p_ell$ <appendix-max-lambda>

This value is used to determine the specific value of $lambda$ when running the benchmarks. To calculate it, we first need to find the local extrema by $(d p_ell) / (d lambda) = 0$:

$
  d / (d lambda) & (e^(-lambda|s|) - e^(-lambda (|s| + 1))) \
  &= -|s| e^(-lambda|s|) - (-(|s| + 1)e^(-lambda (|s| + 1))) \
  &= (|s| + 1)e^(-lambda (|s| + 1)) - |s| e^(-lambda|s|) = 0 \
  &=> e^(-lambda|s|) ( (|s| + 1)e^(-lambda) - |s|) = 0 \
  &=> cases(
    e^(-lambda|s|) = 0 => lambda = infinity,
    quad (|s| + 1)e^(-lambda) - |s| = 0 \
    => e^(-lambda) = (|s|) / (|s| + 1) \
    => -lambda = ln|s| - ln(|s| + 1) \
    => lambda = ln(|s| + 1) - ln|s|
  )
$

The point at $lambda = infinity$ is 0, so it's a minimum. The maximum, i.e., the value of $lambda$ that maximizes the probability of guessing a length $|s|$ is $lambda = ln((|s| + 1) / (|s|))$

== Length constraints

=== Length greater than

$p_c$ for length greater than, $p_c^>=$, stays the same (i.e., $p_c^>= = p_c$). $p_(ell)^>=$ is different. Namely, the probability distribution $f^>=(x)$ should be 0 before $ell$, since now the string cannot be smaller than $ell$. Then,

$ f^>=(x) = cases(0 & "if" x < ell, c f(x) & "if" x >= ell,) $

for some normalization constant $c$. We can find $c$ by normalizing $integral_0^infinity f^>=(x) d x = 1$

$
  integral_0^infinity f^>=(x) d x
  &= integral_0^ell 0 d x + c integral_ell^infinity lambda e^(-lambda x) d x \
  &= c (-e^(-lambda infinity) - (-e^(-lambda ell))) \
  &= c e^(-lambda ell) = 1 \
  & => c = e^(lambda ell)
$

which gives $c = e^(lambda ell)$. Therefore, the probability is of guessing the length is now:

$
  p^>=_(ell)
  &= integral_(|s|)^(|s| + 1) f^>=(x) d x
  = e^(lambda ell) integral_(|s|)^(|s| + 1) f(x) d x
  = p_ell dot e^(lambda ell) \
$

And the log of the probability is:

$ ln(p^>=_ell) &= ln(p_ell) + lambda ell $

And since $p^>=_c = p_c$, then the overall form is

$ ln(p^>=_s) = ln(p_s) + lambda ell $

// So the help is: $ h^>=
// = 1 - (ln(p_ell) + lambda ell) / ln(p_ell)
// = 1 - 1 - (lambda ell) / ln(p_ell)
// = (lambda ell) / ln(p_ell) $
So the help is: $ h^>=
&= 1 - (ln(p_s) + lambda ell) / (ln(p_s)) \
&= 1 - 1 - (lambda ell) / ln(p_s)\
&= (lambda ell) / ln(p_s) \ $

The value of $ln(p_s)$ can be calculated as shown in @eq-ln-ps does not depend on $ell$ (nor $h^>=$).

And, solving for $ell$ we get $ell = (h^>= ln(p_s)) / lambda$

=== Length less than

This constraint uses a similar logic to "length greater than". Namely, we make the probability density $0$ at points after $ell$, so

$ f^<(x) = cases(0 & "if" x >= ell, c f(x) & "if" x < ell,) $

Carrying out the normalization integral $integral_0^infinity f^<(x) d x = 1$, we get that

$
  integral_0^infinity f^<(x) d x
  &= c integral_0^ell lambda e^(-lambda x) d x + integral_ell^infinity 0 d x \
  &= c (-e^(-lambda ell) - (-e^(-lambda 0))) \
  &= c (1 - e^(-lambda ell)) = 1 \
  & => c = 1 / (1 - e^(lambda ell))
$
$
  p^<_(ell)
  &= integral_(|s|)^(|s| + 1) f^<(x) d x
  = 1 / (1 - e^(-lambda ell)) integral_(|s|)^(|s| + 1) f(x) d x
  = p_ell / (1 - e^(-lambda ell)) \
$

And

$ ln(p^<_s) = ln(p_s) - ln(1 - e^(-lambda ell)) $

So the help is

$
  h^<
  = (ln(p_s) - ln(1 - e^(-lambda ell)) - ln(p_s)) / (-ln(p_s))
  = ln(1 - e^(-lambda ell)) / ln(p_s)
$

Solving for $ell$ here is a bit more cumbersome, but not too complicated.

$
  h^< &= ln(1 - e^(-lambda ell)) / ln(p_s) \
  h^< ln(p_s) &= ln(1 - e^(-lambda ell)) \
  e^(h^<) p_s &= 1 - e^(-lambda ell) \
  e^(-lambda ell) &= 1 - e^(h^<) p_s \
  -lambda ell &= ln(1 - e^(h^<) p_s) \
  ell &= ln(1 - e^(h^<) p_s) / (-lambda) \
$

=== Length equals

This constraint does not have a parameter. Since we know the length, $p^=_ell = 1$ so $p^=_s = p_c = p_s / p_ell$ so

$ h^= = (ln(p_s) - ln(p_ell) - ln(p_s)) / ln(p_s) = ln(p_ell) / ln(p_s) $

// ==

// $
//   h^(tack.r) &= 1 - (C e^lambda)^(-|partial s|) \
//   (C e^lambda)^(-|partial s|) &=1 - h^(tack.r) \
//   -|partial s| &= ln(1 - h^(tack.r)) / ln(C e^lambda) \
//   |partial s| &= -ln(1 - h^(tack.r)) / ln(C e^lambda) \
// $,

== Substring constraints

=== Prefix of and suffix of

These two are identical in terms of help calculation, the only thing that changes is whether you choose the first characters or the last ones. We use $x^*$ as a way of saying any quantity $x$ for either the "prefix of" or "suffix of" constraint (i.e., $h^*$, $p_s^*$, etc.).

#let sub = $partial s$
#{
  let hsp = $h^(tack.r)$ // Help specific prefix
  let hss = $h^(tack.l)$ // Help specific suffix
  let pellsp = $p^(tack.r)_(ell)$
  let pellss = $p^(tack.l)_(ell)$
  let pcsp = $p^(tack.r)_c$
  let pcss = $p^(tack.l)_c$

  [
    Given a substring $sub$, there is an implied constraint that $|X| >= |sub|$, so $pellsp = pellss = p_(ell)^(>=)$.

    In this constraints, $p_c^*$ does now change. Namely, without the constraint we have $p_c = C^(-|s|)$ (a $1 / C$ chance of guessing each character in $|s|$). And $p_c^* = C^(|sub| - |s|)$, since we have $|sub|$ less characters to guess. The log of $p_c^*$ is

    $ ln(p_c^*) = (|sub| - |s|) ln(C) = ln(p_c) + |sub| ln(C) $

    and the help then is:

    $
      hsp = hss = h^*
      &= 1 - (ln(p_s^*)) / ln(p_s) \
      &= 1 - (ln(p_s) + |sub|ln(C) + lambda|sub|) / ln(p_s) \
      &= 1 - 1 - (|sub|ln(C)) / ln(p_s) \
      &= |sub| (ln(C) + lambda) / (-ln(p_s)) \
    $

    And, converselty, $|sub| = h^* (-ln(p_s)) / (ln(C) + lambda)$.
  ]
}

=== Substring

#let ps = $p^(tack.t)$
#let hs = $h^(tack.t)$

Contains is similar except that $ps_c$ is not $C^(|sub| - |s|)$ since we remove $|sub|$ characters, but we have to guess where the substring is placed. Therefore, we need to divide by the amount of slots left, which is $|s| - |sub| + 1$ (adding one because we need to include both edges). So, $ps_c = C^(|sub| - |s|) / (|s| - |sub| + 1)$. We have to be careful since $|s| - |sub| + 1$ can be greater than $C^(|sub|)$ (e.g., $C = 2$, $|s| = 1000$, $|sub| = 2$, we get $C^(|sub|) = 2^2 = 4$ and $|s| - |sub| + 1 = 999$), which means the probability of guessing would _decrease_. A solver should ignore this help if given, so we have to clamp the value to be at least $0$. Therefore, $ps_c = max(C^(|sub| - |s|) / (|s| - |sub| + 1), 0)$

We can calculate the log of $ps_s$ by using the fact that, for nonnegative $x$ and $y$, $ln(max(x, y)) = max(ln(x), ln(y))$.

$ ln(ps_s) = max(ln(p_s) + |sub| ln(C) - ln(|s| - |sub| + 1), 0) $

so the help is

$ hs = (|sub| ln(C) - ln(|s| - |sub| + 1)) / (-ln(p_s)) $

This is a transcendental equation that cannot be rearranged to solve for $|sub|$, but the value can be found for any given instance using binary search, since this function is monotonically increasing with respect to $|sub|$. To spell it out, you can set a lower bound to $0$, upper bound to $|s|$, calculate the help given by the average of the lower and upper bounds, and update the bounds accordingly: if the help is greater, set the upper bound to the current guess, otherwise set the lower bound to the current.

#pagebreak(weak: true)
= Use of LLMs

This bachelor thesis is human-made. Large language models (in particular, Claude Sonnet 4) were occasionally used in this project for writing the code to make plots. A few of the queries used where:

- "I am generating this scatter plot in a log-log scale: ```py
a, b = compare_col("z3", 0.0, 0.9, "runtime")
plt.scatter(a, b / a)
```
Can you help me convert it to a heatmap (making the squares look equal in the log-log scale)?"

- "I'm getting `ValueError: data type <class 'numpy.object_'> not inexact` when doing a t-test on some data I have in a polars dataframe. What is wrong?"

- "I have some bins with data and I want to plot the mean and asymmetric error bars. How can I do that in Python?"

- "How can I show a shaded triangle on a heatmap I'm drawing using plt.colorbar(im, ax=ax)?"

A few other queries were used for miscellaneous tasks, such as:

- "What indexes do i need to add to sqlite to make this query run faster? ```sql select count(1) from problem join solution as s1 on s1.problem_id = problem.id join solution as s2 on s2.problem_id = problem.id where s1.implementation = "z3str3" and s1.sat = 'sat' and s2.implementation = "z3-noodler" and s2.sat = 'sat'```?"

- "I'm getting `ValueError: data type <class 'numpy.object_'> not inexact` when doing a t-test on some data I have in a polars dataframe. What is wrong?"

- "How can I do Rust ```rust escape_unicode``` on a ```rust Cow<str>``` and not mutate the string if no escaping is necessary?"

Generally, these were used as a starting point, and all results were checked by a human.

#v(1cm)
#link("https://brainmade.org/")[#align(center, image("/assets/brain-made-logo.svg"))]
