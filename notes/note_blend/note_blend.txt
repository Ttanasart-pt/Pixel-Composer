<v 1.20.9/>
<script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
Blending surfaces is a fundamental step in any VFX process. Blend node allows you to combine 2 surfaces 
under different blend equation.

## <junc Blend Mode/>

<junc Blend mode> control how the surface is being mixed. Blend modes available in the this node are:

The examples are blend of 2 surfaces:

<img blend_sample>

<table class="ccc203050">
    <tr>
        <th>Mode</th>
        <th>Operation</th>
        <th>Example</th>
    </tr>
    <tr>
        <td>Normal</td>
        <td>$$C_{out} = C_{fg}C_{fg.a} + C_{bg}(1-C_{fg.a})$$</td>
        <td><img-deco blend_normal></td>
    </tr>
    <tr>
        <td>Add</td>
        <td>$$C_{out} = C_{fg} + C_{bg}$$</td>
        <td><img-deco blend_add></td>
    </tr>
    <tr>
        <td>Subtract</td>
        <td>$$C_{out} = C_{fg} - C_{bg}$$</td>
        <td><img-deco blend_subtract></td>
    </tr>
    <tr>
        <td>Multiply</td>
        <td>$$C_{out} = C_{fg}C_{bg}$$</td>
        <td><img-deco blend_multiply></td>
    </tr>
    <tr>
        <td>Screen</td>
        <td>$$C_{out} = 1 - (1-C_{fg})(1-C_{bg})$$</td>
        <td><img-deco blend_screen></td>
    </tr>
    <tr>
        <td>Overlay</td>
        <td>$$C_{out} = \begin {cases} 2C_{fg}C_{bg} & C_{fg} < 0.5 \\ 1 - 2(1-C_{fg})(1-C_{bg}) & C_{fg} \ge 0.5 \end {cases}$$</td>
        <td><img-deco blend_overlay></td>
    </tr>
    <tr>
        <td>Hue</td>
        <td>Transfer the hue of the foreground to the background</td>
        <td><img-deco blend_hue></td>
    </tr>
    <tr>
        <td>Saturation</td>
        <td>Transfer the saturation of the foreground to the background</td>
        <td><img-deco blend_saturation></td>
    </tr>
    <tr>
        <td>Luminosity</td>
        <td>Transfer the luminosity of the foreground to the background</td>
        <td><img-deco blend_luminosity></td>
    </tr>
    <tr>
        <td>Maximum</td>
        <td>$$C_{out} = max(C_{fg}, C_{bg})$$</td>
        <td><img-deco blend_maximum></td>
    </tr>
    <tr>
        <td>Minimum</td>
        <td>$$C_{out} = min(C_{fg}, C_{bg})$$</td>
        <td><img-deco blend_minimum></td>
    </tr>
    <tr>
        <td>Replace</td>
        <td>$$C_{out} = C_{fg}$$</td>
        <td><img-deco blend_replace></td>
    </tr>
    <tr>
        <td>Difference</td>
        <td>$$C_{out} = |C_{fg} - C_{bg}|$$</td>
        <td><img-deco blend_difference></td>
    </tr>
</table>

### <junc Opacity>

The intensity of the effect will be multiply by the <junc Opacity> property.

### <junc Preserve Alpha>

Blend operation apply to all channel including alpha channel. Which mean some operation may erase the 
alpha channel of the original image. To exclude the alpha calculation, set <junc Preserve Alpha> to true.

## Dimension Mixing

When blending surfaces of different sizes. You can set the blending behaviour using several properties:

### <junc Fill mode>

The <junc Fill mode> property control the behaviour of the smaller surface.

<table class="cc4060">
    <tr>
        <th>Mode</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>None</td>
        <td>Do nothing, place smaller surface directly.</td>
    </tr>
    <tr>
        <td>Stretch</td>
        <td>Stretch the smaller surface to fit the larger surface.</td>
    </tr>
    <tr>
        <td>Tile</td>
        <td>Tile the smaller surface to fit the larger surface.</td>
    </tr>
</table>

### <junc Position>

When <junc Fill mode> is set to None, you can set the position of the <junc foreground> freely using the <junc position> property.
