function Node_PCX_fn_Surface_Height(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name  = "Surface Height";
	
	newInput(0, nodeValue("Surface", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	outputs[0] = nodeValue_Output("PCX", self, VALUE_TYPE.PCXnode, noone);
	
	static update = function() {
		var _surf = getInputData(0);
		outputs[0].setValue(new __funcTree("surface_get_height", [ _surf ]));
	}
}