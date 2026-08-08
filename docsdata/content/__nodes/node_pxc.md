Load another Pixel Composer project and output surface connected to <node Node_Export> node.

## Properties

[proptable]
Project
Path|File path.

Animation
Animated|Update new frame during animation.
Loop Mode|Loop settings.\n
 - **Loop**: Loop animation infinitly.\n
 - **Ping pong**: Loop animation by playing backward.\n
 - **Hold last frame**: Freeze first/last frame.\n
 - **Hide**: Display nothing.
Frame Start|Set starting frame.
Draw Before Start|Whether to draw before start (subjects to <junc Loop mode> setting) or display nothing.
Fractional Frame|Allow rendering fractional frame index (e.g. for slow-mo effect). Will not work with simulation-type nodes.
[/proptable]
