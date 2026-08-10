Match surface pattern and replace with different surface.

## Properties

[proptable]
Matching
Match|Pattern to match.
Match Group|Colors in these group will be treat as the same color.
Threshold|Maximum different between two pixels to still be consider the same color.
Transform|Apply match to rotated, flip surface.
Boundary|Method for dealing with boundary pixels:\n
 - **Ignore**: Treat overflow pixel as always matched.\n
 - **Stop**: Treat overflow pixel as always unmatched.\n
 - **Clamp**: Clamp pixel edge.
 
Tiling
Tiling|Spaced out pattern matching in tile instead of overlapping per pixels.

Replacement
Replace|Pattern to replace to.
Replace Chance|Chance to replace.
Maximum Count|Set the limit of how many replacements can be done. Set to zero for no limit.
Transform|Apply random transformation.
Reverse Order|Reverse replacement order.
[/proptable]
