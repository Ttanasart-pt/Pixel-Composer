function Node_PB_Dimension(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Dimension";
	setDimension(96, 48);
	
	newOutput(0, nodeValue_Output("Dimension", self, VALUE_TYPE.float, [ 1, 1 ] ))
	    .setDisplay(VALUE_DISPLAY.vector);
	
	static update = function() {
	    outputs[0].setValue(group.dimension);
	}
}
