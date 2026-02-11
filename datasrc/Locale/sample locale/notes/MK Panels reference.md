MK Panels is a node for generating random industrial panels. It consists of 2 processes, Panel generation and Shape drawing. Each process relies on a "Pattern" string which defines a set of rules.

The node will repeatedly select one random symbol from the pattern and apply it to the panel until the minimum size is reached or the maximum number of iterations is reached. 

A pattern can contain duplicate symbols to increase the chance of it being selected.

## Panel Pattern Symbols

{g}
<x20> [x]    <x60>  Split X axis
<x20> [y]    <x60>  Split Y axis
<x20> [h(n)] <x60> Split X axis (n) parts equally
<x20> [v(n)] <x60> Split Y axis (n) parts equally
<x20> [i]    <x60>  Inset
<x20> [I]    <x60>  Inset uniform
<x20> [f]    <x60>  Frame
<x20> [F]    <x60>  Frame uniform
<x20> [e]    <x60>  Empty frame
<x20> [E]    <x60>  Empty frame uniform
<x20> [C]    <x60>  Corner
{g}

## Shape Pattern Symbols

{g}
<x20> [r]  <x60> Rectangle
<x20> [d]  <x60> Cut cornered Rectangle
<x20> [c]  <x60> Round cornered Rectangle
<x20> [P]  <x60> Shaded pipes
<x20> [*s] <x60> Add slots
{g}

## Initial Symbols

You can control the first nth iteration to be a specific symbol by adding the "|" character. The symbol before the "|" will be used for the first nth iteration. For example, "x|xy" will use "x" for the first iteration and "xy" for the rest.