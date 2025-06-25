#import "/utils.typ": z3str3, z3-noodler

#let dark-mode = false;

#let bg = color.oklch(98%, 3%, 60deg)
#let bg2 = bg.desaturate(20%).lighten(50%)
#let accent = color.oklch(75%, 76%, 270deg) // Maybe too saturated
#let accent = z3str3.color.desaturate(20%)
#let accent = z3-noodler.color
#let black = color.oklch(1%, 93%, 106.41deg)
#let gray = color.oklch(45%, 00%, 0deg)

#if dark-mode {
  bg = color.oklch(9%, 45%, 503deg)
  bg2 = bg.darken(20%)
  accent = color.oklch(15%, 76%, 320deg) // Maybe too saturated
  black = color.oklch(90%, 4%, 287deg)
  gray = color.oklch(55%, 00%, 0deg)
}
