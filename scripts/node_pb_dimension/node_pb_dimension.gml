function Node_PB_Dimension(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Dimension";
	color = COLORS.node_blend_feedback;
	setDimension(96, 48);
	
	newOutput(0, nodeValue_Output("Dimension", self, VALUE_TYPE.float, [ 1, 1 ] ))
	    .setDisplay(VALUE_DISPLAY.vector);
	
	newOutput(1, nodeValue_Output("Width", self, VALUE_TYPE.float, 1 ))
		.setVisible(false)
	
	newOutput(2, nodeValue_Output("Height", self, VALUE_TYPE.float, 1 ))
		.setVisible(false)
	
	static update = function() {
	    outputs[0].setValue(group.dimension);
	    outputs[1].setValue(group.dimension[0]);
	    outputs[2].setValue(group.dimension[1]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_pb_dimension, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
}
