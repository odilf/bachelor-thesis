#import "./styling.typ": styling
#import "/utils.typ": todo

#show: styling

#include "./title.typ"

#counter(page).update(1)
#metadata("body-start")
#include "./body/main.typ"
#pagebreak(weak: true)

#bibliography("references.bib")
#pagebreak(weak: true)

#counter(heading).update(0)
#include "./appendix.typ"

