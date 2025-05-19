#import "/utils.typ": todo

= Responsible Research <responsible-research>

Before discussing the results, we want to spend a few paragraphs on a somewhat unorthodox reflection about making responsible research. For, despite most of the "usual suspects" of unethical investigation are not present in this paper (there's no Machine Learning #todo[Should this be capitalized?], no training dataset, no massive use of computing/natural resources, no consequences #todo[not quite] in highly critical infrastructure, etc) there are considerations we can take about the effect of the results presented in the paper.

== Integrity <responsible-research-reproducibility>

As explained in @runner-and-reproducibility, careful design and using Nix allows for practically trivial, 100% accurate reproduction of the testing infrastructure. That does not imply that the results themselves are 100% reproducible, since the specifics of runtime and number of executed instructions depend on the underlying architecture of the machine, but any person with access to a Linux or MacOS machine (with either x86 or ARM architecture) can easily run the benchmarking suite and verify the result themselves. Even if the results are not identical, we expect them to reach the same conclusions. In fact, finding that some computing platform doesn't follow the results found in this paper would be highly insightful in of it itself.

Reproducibility is important both for the integrity of the results (we have no room for lying, since anyone can verify them), but also to democratize the advancement knowledge. We allow and encourage any interested person to use our runner, or modify it to find new knowledge. We don't require any payment or any special institutional access. The only necessary tools (a computer and an initial internet connection) are by necessity, not by choice. 

== The bigger picture

The presented research is pretty self contained, so it's hard to find problem within. However, we still need to think about the bigger picture. For instance, the first line of the paper is an anecdote about how Amazon does 1 billion SMT queries a day. If we help to improve Z3, we might be indirectly helping Amazon, which is arguably considered widely unethical #todo[do I need to justify this?]. So is the presented research unethical too by association?

We would say that the answer is, generally, no --- for two reasons. Firstly, the SMT queries at Amazon are pretty far removed from the specifics of the unethical things they do, so any help we give them in that regard is miniscule. And secondly, as we said before, the code is free, open source, and very easy to use, so Amazon has no more advantage than a university researcher or a hobbyist in their bedroom.

However, it can't be denied that to some degree, even if small, we _are_ giving our labor to unethical enterprises. And if we zoom out even more, we rely on Microsoft's GitHub to distribute the code, for the entiritey of Nix's ecosystem, most of the energy used in researching, writing the bencharking suite and running the benchmark themselves was not clean, and, of course, Z3 is a Microsoft product.

It is basically impossible to be completely ethical, by its most stringent definition, while living in current society. So, looking at the bigger picture, it is hard to argue that the research presented today does any more harm to society than any reasonable expectation of a person's participation in it.
