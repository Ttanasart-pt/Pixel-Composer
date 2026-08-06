Bar/Graph node is used to plot graph using array of number. While initialliy created for audio visualization, 
it can be use to create interesting shape as well.

## Data Processing

[proptable]
Value Offset|Add or subtract all values with a fixed amount.
Flip Value|Invert the sign of the data.
Trim mode|Set the data trimming mode.
Range|Range of the data trimming.
Sample frequency|Sample data at every N values instead of all values.
[/proptable]

## Plot Properties

[proptable]
Type|Set the type of plot.
Origin|The origin position.
Direction|The direction where each subsequence data go.
Path|The path to draw the plot on. If using path, the <junc Direction> property will be disabled.
Scale|The scale of the plot.
[/proptable]

The graph type open up to more controls:

[proptable]
Loop|Add line connecting the last and first data.
Smooth|Smooth out the value with moving average.
[/proptable]

## Render Properties

Properties in this section are all related to rendering.

[proptable]
Base Color|Base color of the plot
Color Over Sample|Color to blend per each value (based on the index)
Color Over Value|Color to blend based on the value
Value range|The range for the <junc Color Over Value> property. e.g. if the range is [0, 10] then value 5 will correspond to the middle of the gradient
Absolute|Apply absolute to the value before calculating <junc Color Over Value>
Bar Width|The width of each bar
Rounded Bar|Use capsule bar shape instead of rectangle
Graph Thickness|The thickness of the graph line
Spacing|The distance between each data point
Background|Background Color
[/proptable]
