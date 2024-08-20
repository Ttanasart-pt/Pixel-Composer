function Node_PCX_fn_Surface_Width(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name  = "Surface Width";
	
	newInput(0, nodeValue("Surface", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	outputs[0] = nodeValue_Output("PCX", self, VALUE_TYPE.PCXnode, noone);
	
	static update = function() {
		var _surf = getInputData(0);
		outputs[0].setValue(new __funcTree("surface_get_width", [ _surf ]));
	}
}