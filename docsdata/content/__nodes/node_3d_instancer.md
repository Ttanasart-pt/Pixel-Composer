Create multiple copies of a 3D model using instancing.

## Properties

[proptable]
Object
Mesh|Base model

Repeat
Pattern|Instancing pattern.
Amounts|Instance count for **Linear** and **Circular** patterns.
Grid|Grid subdivision in **Grid** pattern.
Radius|**Circular** pattern radius.
Look At Center|Rotate instances toward center point.

Path
Path|Places instances along path.
Follow Path|Rotate instances along path.

Transform Data (Apply direct array of data to transform each instance directly.)
Positions|Array of vec3s for position.
Rotations|Array of quaternions for rotation.
Scales|Array of vec3s for scale.
Normals|Array of vec3s for normal.

Shift (Transform each instance accumulatively)
Shift Position|Shift each new instance for **Linear** and **Circular** patterns.
Shift Position Y|Shifting amount for Y axis in **Grid** pattern.
Shift Position Z|Shifting amount for Z axis in **Grid** pattern.
Shift Rotation|Rotate each new instance by a fix amount.
Shift Scale|Scale each new instance by a fix amount.

Scatter (Transform each instance randomly)
Position Scatter|Random shift in position.
Rotation Scatter|Random shift in rotation.
Scale Scatter|Random shift in scale.
Scale Uniform|Apply the same scale factor to all axes.

Render
Colors Per Index|Apply color blending by order.
Random Colors|Apply random color sampled from a gradient.
[/proptable]

## Instancing vs. Repeat

This node is similiar to <node Node_3D_Repeat>. The main different is this node use instancing to create a clone while <node Node_3D_Repeat> 
create multiple objects. 

<table class="cc5050">
	<tr>
        <th>Instancing</th>
        <th>Repeat</th>
    </tr>
    <tr>
        <td>Faster for large amount of copies.</td>
        <td>Slower but no extra compile time.</td>
    </tr>
    <tr>
        <td>Less flexible (cannot used with <node Node_3D_Affector>).</td>
        <td>More flexible.</td>
    </tr>
</table>

