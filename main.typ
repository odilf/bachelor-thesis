#import "./styling.typ": styling

#show: styling

#include "./title.typ"

#metadata("body-start")
#include "./body/main.typ"
#pagebreak(weak: true)

#bibliography("references.bib")

#include "./appendix.typ"

