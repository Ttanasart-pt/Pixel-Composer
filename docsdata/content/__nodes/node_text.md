Draw text to surface.

## Properties

[proptable]
Text
Text|Text to draw.
Change Case|(For latin alphabet) Change text case.

Output
Dimension|Dimension type:\n - Fixed: Fixed size from vec2 value.\n - Dynamic: Set size automaticaly to fit the text content.
Offset|Shift draw position.
Padding|Add extra space in 4 directions.
Atlas|Output each character as array of surface atlases.

Font
Font|Text font.
Size|Font size.
Scale to Fit|Scale text size to fit output dimension (in fixed mode).

Font Settings
Fallback Font|Seconds font to use if a glyph is not existed in the main <junc Font>
Use SDF|Use sdf to draw text.

Letter Settings
Letter Spacing|Add extra horizontal space between letters.
Line Height|Add extra vertical space between lines.
Monospaced|Force each letter to has different width.

Alignment
Max Line Width|Maximum line width before entering new line (in dynamic mode).
Split Word|When breaking into new line, whether to use space to divide word or split letter directly.
H Align|Horizontal alignment.
V Align|Vertical alignment.

Path (Fixed mode recommended)
Path|Draw text along path.
Path Shift|Shift text along path.
Rotate Along Path|Rotate text to path direction.

Rendering
Round Position|Round letter position to integer to prevent anti-aliasing.
Color|Base text color.
Color by Letter|Multiply color by letter.
Texture|Apply texture to each letter.

Background
BG Color|Background color.
Background|Add background surface, stretch to output dimension.

Wave
Wave|Move text in wave pattern.
Wave Shape|Wave shape (0:Sin, 1:Triangle, 2:Square, 3:Sawtooth)
Wave Amplitude|Wave size.
Wave Scale|Wave width (how many letter can be affected by wave).
Wave Phase|Wave position.

Trim (Typewriter effect)
Trim|Enable trim effect.
Trim Type|Trim type.
Range|Trim range.
Use Full Text Size|Force dynamic dimension to always fit the full text not trimed.
[/proptable]
