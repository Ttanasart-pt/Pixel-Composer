Downscale a surface. Can be use for SSAA as a normal <node Node_Transform> downscaling does not combine pixels.

## Properties

[proptable]
Scale
Mode|Downscale mode:\n
 - **Mix**: Combines all pixel to create SSAA effect.\n
 - **Max**: Get maximum (brightest) pixel.\n
 - **Min**: Get minimum (darkest) pixel.
Downscale|Downscaling factor (larger number = smaller output.)
Multiply Alpha|Multiply opacity to rgb value for mix mode.
[/proptable]
