<v 1.18.1/>
Import multiple images file as a single animated image.

### Properties

#### <junc path>
Array of path to the images files.

#### <junc padding>
Apply extra padding in each images.

#### <junc canvas size>
Define the canvas size to use when importing images with different sizes.

- **First**: The canvas size will be the size of the first image.
- **Maximum**: The canvas size will be the largest image size.
- **Minimum**: The canvas size will be the smallest image size.

#### <junc loop modes>
Define the loop mode of the animation.

- **Loop**: The animation will loop indefinitely.
- **Ping Pong**: The animation will loop backward when finished.
- **Hold last frame**: The animation will stop and freeze at the last frame.
- **Hide**: The animation will stop and disappear after the last frame.

#### <junc stretch frame>
Stretch the animation to fit the project animation length.

#### <junc animation speed>
How fast the animation will play (in animation frame per project frame).

#### <junc custom frame order>
Whether to control the animation frame manually using the <junc frame> input.