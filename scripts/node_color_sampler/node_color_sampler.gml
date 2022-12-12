function Node_create_Sampler(_x, _y) {
	var node = new Node_Sampler(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Sampler(_x, _y) : Node(_x, _y) constructor {
	name = "Sampler";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	outputs[| 1] = nodeValue(1, "Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my);
	}
	
	_input = -1;
	static update = function() {
		var _surf = inputs[| 0].getValue();
		if(!is_surface(_surf)) return;
		if(_input != _surf) {
			outputs[| 0].setValue(_surf);
			_input = _surf;	
		}
		var _pos = inputs[| 1].getValue();
		
		var cc   = surface_getpixel(_surf, _pos[0], _pos[1]);
		
		outputs[| 1].setValue(cc);
	}
}