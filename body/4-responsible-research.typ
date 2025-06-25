#import "/utils.typ": todo

= Responsible Research <responsible-research>

Before discussing the results, we want to spend a few paragraphs on a somewhat unorthodox reflection (which a busy reader can skip) about making responsible research. For, despite most of the "usual suspects" of unethical investigation are not present in this paper (there is no Machine Learning, no training dataset, no massive use of computing/natural resources, no direct consequences in highly critical infrastructure, etc.) there are considerations we can take about the effect of the results presented in the paper.

== Integrity <responsible-research-reproducibility>

As explained in @runner-and-reproducibility, careful design and using Nix allows for practically trivial, 100% accurate reproduction of the testing infrastructure. That does not imply that the results themselves are 100% reproducible, since the specifics of runtime and number of executed instructions depend on the underlying architecture of the machine. However, any person with access to a Linux or MacOS machine (with either x86 or ARM architecture) can easily run the benchmarking suite and verify the result themselves. Even if the results are not identical, we expect them to reach the same conclusions (in fact, finding that some computing platform does not follow the results found in this paper would be highly insightful in of it itself).

Reproducibility is important both for the integrity of the results (we have no room for lying, since anyone can verify them), but also to democratize the advancement knowledge (in an, admittedly, small way). We allow and encourage any interested person to use our runner, or modify it to find new knowledge. We do not require any payment or any special institutional access. The only necessary tools (a computer and an initial internet connection) are by necessity, not by choice. 

== The bigger picture

The presented research is relatively self contained, so it is hard to find problem within. However, we can think about the bigger picture. For example, the first line of the paper is an anecdote about how Amazon does one billion SMT queries a day @rungtaBillionSMTQueries2022. If we help to improve Z3, we might be indirectly helping Amazon, which is arguably considered widely unethical. So is the presented research unethical too by association?

We would say that the answer is, generally, no --- for two reasons. Firstly, the SMT queries at Amazon are very far removed from the specifics of the unethical things they do, so any help we give them in that regard is minuscule. And secondly, as we said before, the code is free, open source, and very easy to use, so any entity in privileged position (such as Amazon) has no more advantage than a university researcher or a hobbyist in their bedroom.

