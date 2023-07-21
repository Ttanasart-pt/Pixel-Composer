function Node_PB_Draw(_x, _y, _group = noone) : Node_PB(_x, _y, _group) constructor {
	name = "PB Draw";
	
	inputs[| 0] = nodeValue("pBox", self, JUNCTION_CONNECT.input, VALUE_TYPE.pbBox, noone )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 2] = nodeValue("Apply Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("pBox", self, JUNCTION_CONNECT.output, VALUE_TYPE.pbBox, noone);
}