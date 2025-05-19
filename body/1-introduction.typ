#import "@preview/wordometer:0.1.4": word-count, total-words
#import "/utils.typ": todo, z3str3
#let tc = todo[cite]

= Introduction <introduction>

// lectures notes:
// - Is it clear and concrete...
//   - ...what we know?
//   - ...what we don't know?
//   - ...how we'll study that?
// - First sentence

// I think this first sentence is pretty strong! If anything, it might be confusing.
Even though SAT is the archetypical NP-complete problem #todo[Do I need to cite this?], which practically means no universally efficient solution exists, it is often necessary find specific solutions in a reasonable amount of time. SMT solvers such as Z3 aim to provide this utiliy #todo[utility? maybe service, but that sounds like it's online.]. Just Amazon alone does one billion daily SMT queries to verify the correctness of their AWS policies #todo[maybe user policies..] @rungtaBillionSMTQueries2022, and they are used extensively in many other areas too @saxenaSymbolicExecutionFramework2010 @emmiDynamicTestInput2007 @kiezunHAMPISolverString2009 @senJalangiSelectiveRecordreplay2013 @backesSemanticbasedAutomatedReasoning2018 @wassermannSoundPreciseAnalysis2007 @redelinghuysSymbolicExecutionPrograms2012 @dantoniPowerSymbolicAutomata2017 #todo[I think they should all should go in one bracket].

#todo[Differentiate more between general vs domain-specific, and just say that tactics are generally what one uses for domain specific modifications.]
As the use-cases become more complex and extensive, better performance is of course desired. While performance gains may come from anywhere, one way to categorize them is between _general purpose_ and _domain-specific_. General purpose improvements usually come in the form of stronger implementations, such as Z3-Noodler (which we will discuss later on #todo[Do I need to say exactly where?]). However, sometimes there is some exploitable property of a problem or a family of problem, that you might want to take advantage of. Z3 provides the _tactics_ mechanism --- where, the user can change some behavior of the solver or subdivide the problem --- ostensibly for this reason (even though domain-specific knowledge can also be manifested as additional "refining" constraints, and tactics don't _have_ to be domain-specific, as clarified in @tactics-vs-domain-specific-knowledge)

A question comes to mind when faced with these two approaches: *are there diminishing returns to using domain-specific guidance as the implementation strength increases?* #todo[Is the bold too much?] It might be the case that a very optimised implementation does some processing that is equivalent or better than the tactics used. This effect would be more pronounced the more general the tactic is, according to this line of reasoning.

In this paper we describe the relationship between solver implementation strength and the effectiveness of domain-specific guidance. The main contributions of the research are: 

+ A systematic way to simulate domain-specific knowledge on arbitrarily large datasets. 
+ Understanding on how the strength of an underlying implementation affects the effectives of these tactics.
+ A reproducible benchmarking suite to test and compare these models, using Nix.
+ Insight on what constraints/tactics might help performance in practice.

// We first give a quick overview of how the selected solvers work, necessary to understand their behavior, in @theoretical-background. In @methodology and @results[] we discuss methodology and show the results. In @discussion we discuss why we see those results and the insight we can gain before concluding the research in @conclusion.
// #todo[This whole paragraph below feels a bit uninspired/copy-pasted]
