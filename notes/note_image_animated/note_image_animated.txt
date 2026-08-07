<v 1.18.1/>
Import multiple images file as a single animated image.

## Properties

[proptable]
Image
Path|Array of path to the images files.
Padding|Apply extra padding in each images.
Canvas Size|Define the surface size to use when importing images with different dimensions.\n
 - **First**: The surface size will be the size of the first image.\n
 - **Maximum**: Use the largest surface dimension.\n
 - **Minimum**: Use the smallest surface dimension.
 
Animation
Loop modes|Define the loop mode of the animation.\n
 - **Loop**: The animation will loop indefinitely.\n
 - **Ping Pong**: The animation will loop backward when finished.\n
 - **Hold last frame**: The animation will stop and freeze at the last frame.\n
 - **Hide**: The animation will stop and disappear after the last frame.
Stretch Frame|Stretch the animation to fit the project animation length.
Animation Speed|How fast the animation will play (in animation frame per project frame).

Custom Order
Custom Frame Order|Whether to control the animation frame manually using the <junc frame> input.
[/proptable]
