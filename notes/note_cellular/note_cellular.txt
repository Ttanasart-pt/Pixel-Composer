## Properties

[proptable]
Noise
Type|Type of the pattern. <img cellular_type/>
Pattern|Cell distribution.\n - Uniform: Distribute the cell randomly across the surface.\n - Radial: Distribute the cell around the <junc position/> value.\n<img cellular_pattern/>
Phase|Noise phase.
Randomness|Cell varience. Set to zero for uniform rectangle grid.

Transform
Position|The position of the pattern, or center point if set to <li><span class="inline-code">Radial</span> pattern.
Scale|Scale of the pattern.

Radial
Radial Scale|Control scaling of the radial effect.
Radial Shatter|Control how many angular fragmentation per radius.

Rendering
Contrast|Control the contrast of the final image.
Middle|The middle point for contrast calculation.
Colored|<span class="inline-code">Cell</span> type only: fill each cell with random color.
[/proptable]