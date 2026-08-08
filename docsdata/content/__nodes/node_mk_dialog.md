Create an animation of multiple set of texts with transition.

## Properties

[proptable]
Text
Dialogs|Array of texts.
Change Case|Change text case (for latin alphabet) before rendering.

Alignment
Max Line Width|Maximum length of the line (in pixel) before entering new line.
H Align|Horizontal alignment
V Align|Vertical alignment
Line Height|Add extra space between each line.

Font
Font|Font to draw.
Size|Font size.

Rendering
Blend Mode|Alpha blend mode. Will have an impact when using tranparent color or anti-aliased font.
Color|Base text color.
Color by Letter|Multiply color by letter.

Background
Render Background|Whether to render background or draw on transparent background.

Timing
Start Frame|Starting frame.
Duration Type|Set method for calculating duration of each dialog:\n
 - **Fixed**: Use the same fix time for all dialog.\n
 - **Letter Count**: Scale by the amount of letter in the dialog.\n
 - **Word Count (space)**: Scale by word count in the dialog separated by space.
Fixed Duration|Set based fixed duration for all dialog.
Multiply Duration|Add extra time per dialog by multipling value set by the <junc Duration Type> with this number.
Dialog Spacing|Add or reduce time between each dialog. Will not affect the dialog duration.

Manual Timer
Manual Timer|Set time manually using the timeline object.
[/proptable]