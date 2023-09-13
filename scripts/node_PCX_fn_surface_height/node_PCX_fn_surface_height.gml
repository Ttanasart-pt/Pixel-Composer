function Node_PCX_fn_Surface_Height(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name  = "Surface Height";
	
	inputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone);
	
	outputs[| 0] = nodeValue("PCX", self, JUNCTION_CONNECT.output, VALUE_TYPE.PCXnode, noone);
	
	static update = function() {
		var _surf = inputs[| 0].getValue();
		outputs[| 0].setValue(new __funcTree("surface_get_height", [ _surf ]));
	}
}