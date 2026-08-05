Create multiple copies of a 3D model using instancing.

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

