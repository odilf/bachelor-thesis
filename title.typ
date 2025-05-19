#import "/utils.typ": todo, DEBUG
#import "@preview/drafting:0.2.2": note-outline

#set par(justify: false)

#let me = "Odysseas Machairas"
#let responsible-prof = "Soham Chakraborty"
#let supervisor = "Dennis Sprokholt"
#let examiner = "Tomas Hölt"

#set par(first-line-indent: 0pt)

// In case I want to copy the layout more exactly...
// https://tex.stackexchange.com/questions/24599/what-point-pt-font-size-are-large-etc

#let title = [Is solver guidance redundant for strong SMT implementations?]
#let subtitle = [An exploration of domain-specific vs general \ improvements applied to Z3's string theories.]

// #if DEBUG [
//   #align(horizon + center)[
//     #text(size: 100pt, weight: "black")[DEBUG MODE] \
//     #v(1cm)
//     Word count: #total-words
//   ]
//   #pagebreak()
// ]

#align(horizon + center)[
  // TODO: Find higher quality TU Delft logo
  #image("assets/tudelftlogo.png", width: 8cm)
  #v(2cm)

  #text(weight: "semibold", 28pt)[
    #title
  ] \
  \
  #text(weight: "thin", 16pt)[
    #subtitle
  ]


  // Not copied verbatim
  #v(1cm)

  #text(size: 1em + 2pt)[
    *#me* \
    *Supervisor(s): #responsible-prof#super[1], #supervisor#super[1]*
  ]

  #super[1] EEMCS, Delft University of Technology, The Netherlands

  #v(1.5cm)

  A Thesis Submitted to EEMCS Faculty Delft University of Technology, \
  In Partial Fulfilment of the Requirements \
  For the Bachelor of Computer Science and Engineering \
  #datetime.today().display("[month repr:long] [day], [year]")

  #v(2cm)

]

#text(size: 1em - 1pt)[
  Name of the student: #me \
  Final project course: CSE3000 Research Project \
  Thesis committee: #responsible-prof, #supervisor, #examiner \
]

#align(center + bottom)[

  An electronic version of this thesis is available at #todo[http://repository.tudelft.nl/]
]

#pagebreak()

#if DEBUG {
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: none,
    note-outline(level: 2),
    outline(),
  )
  pagebreak(weak: true)
}
