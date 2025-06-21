#import "/utils.typ": todo, DEBUG, TIDY-DEBUG, REDACTED, info
#import "@preview/drafting:0.2.2": note-outline

#set par(justify: false)

#set par(first-line-indent: 0pt)
// In case I want to copy the layout more exactly...
// https://tex.stackexchange.com/questions/24599/what-point-pt-font-size-are-large-etc

#align(horizon + center)[
  // TODO: Find higher quality TU Delft logo
  #image("assets/tudelftlogo.png", width: 8cm)
  #v(2cm)

  #text(weight: "semibold", 28pt)[
    #info.title
  ] \
  \
  #text(weight: "thin", 16pt)[
    #info.subtitle
  ]


  // Not copied verbatim
  #v(1cm)

  #text(size: 1em + 2pt)[
    *#info.author* \
    *Supervisor(s): #info.responsible-prof#super[1], #info.supervisor#super[1]*
  ]

  #super[1] EEMCS, Delft University of Technology, The Netherlands

  #v(1.5cm)

  A Thesis Submitted to EEMCS Faculty Delft University of Technology, \
  In Partial Fulfilment of the Requirements \
  For the Bachelor of Computer Science and Engineering \
  #datetime.today().display("[month repr:long] [day], [year]")

  #v(2cm)

]

#if TIDY-DEBUG {
  highlight[#text(size: 1em + 10pt)[*Red dagger (#todo[]) indicates TODOs*] \
  _(full TODO text available in regular debug version.)_
  ]
} else {
  text(size: 1em - 1pt)[
    Name of the student: #info.author \
    Final project course: CSE3000 Research Project \
    Thesis committee: #info.responsible-prof, #info.supervisor, #info.examiner \
  ]
}

#align(center + bottom)[

  An electronic version of this thesis is available at http://repository.tudelft.nl/
]

#pagebreak(weak: true)

// #if DEBUG and not REDACTED {
//   table(
//     columns: (1fr, 1fr),
//     inset: 0pt,
//     stroke: none,
//     note-outline(level: 2),
//     outline(),
//   )
//   pagebreak(weak: true)
// }
