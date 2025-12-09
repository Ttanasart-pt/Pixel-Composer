function Node_PB_Dimension(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Dimension";
	color = COLORS.node_blend_feedback;
	setDrawIcon(s_node_pb_dimension);
	setDimension(96, 48);
	
	newOutput(0, nodeValue_Output("Dimension", VALUE_TYPE.float, [ 1, 1 ] ))
	    .setDisplay(VALUE_DISPLAY.vector);
	
	newOutput(1, nodeValue_Output("Width", VALUE_TYPE.float, 1 ))
		.setVisible(false)
	
	newOutput(2, nodeValue_Output("Height", VALUE_TYPE.float, 1 ))
		.setVisible(false)
	
	static update = function() {
	    outputs[0].setValue(group.dimension);
	    outputs[1].setValue(group.dimension[0]);
	    outputs[2].setValue(group.dimension[1]);
	}
	
}
