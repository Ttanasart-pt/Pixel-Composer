2D Light node draw a light on top of original surface. If you want the light to cast a shadow, check 
out <node shadow_cast>.

## Light Properties

### <junc light shape/>

Control the shape of the light. There are 4 available shapes: Point, line, line asymmetric, and spot.

<img 2d_light_shape>

### <junc range/>

The size of the light.

### <junc intensity/>

The brightness of the light. Adjusting this amount may effect the resulting range.

### <junc color/>

Control color of the light. Note that light use additive blending.

### <junc attenuation/>

Control the falloff of the light. There are 3 available falloff: quadratic, invert quadratic and linear.

<img 2d_light_attenuation>

### <junc banding/>

Banding convert smooth light to discrete steps. The banding width depends on the <junc attenuation/>.

<img 2d_light_banding>

## Radial Properties

With point light, you can use <junc radial banding/> to add the "shine" effect to the light.

### <junc radial banding/>

The amount of radials, set to 0 for a full circle.

### <junc radial start/>

Rotate the radial effect.

### <junc radial band ratio/>

The width of the radial band as a ratio. 0 means no light and 1 mean fulll circle.

<img 2d_light_radial_banding>
