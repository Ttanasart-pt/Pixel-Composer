Draw a line to surface.

## Properties

[proptable]
Background
Background|Background type
BG Color|Background color
BG Surface|Background surface

Line Data
Data Type|Type of data to draw the line from.
Force Loop|Add extra line between the last point to the first.
Fix Length|Whether to draw fixed amount of segments (off), or fix the length of each segment (on) to keep path resolution no matter the length.

Width
1px Mode|Draw a pixel perfect 1px width line.
Width|Width of the line. Randomized per segment.
Span Width over Path|Scale width curve (if used) to the current <junc Range> value.

Weight
Apply Weight|Apply path weight to line width.

Line Settings
Range|Trim line relative to input length.
Invert|Reverse path direction.
Shift|Shift position on the original data.
Clamp Range|Clamp range after shift to between [0,1].

Dash Line
Dash|Draw dashed line.
Dash Line|Length of dash vs. spacing.
Dash Shift|Shift dash position.

Wiggle
Use Wiggle|Randomly shift each segment.
Amplitude|Amount of shifting.
Frequency|Wiggle frequency.
Detail|Level of wiggle detail.
Phase|Shift wiggling wlong the line.
Trim Range|Scale wiggle curve (if used) to the current <junc Range> value.

Line Caps
Start Cap|Shape of start cap.
End Cap|Shape of end cap.

Color
Color over Length|Line color over length.
Random Blend|Base color. Random per line.
Span Color over Path|Scale <junc Color over Length> to the current <junc Range> value.
Color Weight|Color line based on weight.

Texture
Texture|Add texture to line.

Render
SSAA|Draw line on larger surface then scaled down for anti-aliasing.
[/proptable]
