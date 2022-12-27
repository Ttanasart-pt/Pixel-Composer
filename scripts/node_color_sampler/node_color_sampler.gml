function Node_Sampler(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Sampler";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	outputs[| 0] = nodeValue(0, "Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	static getPreviewValue = function() { return inputs[| 0]; }
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	function process_data(_output, _data, index = 0) { 
		var _surf = _data[0];
		var _pos = _data[1];
		if(!is_surface(_surf)) return c_black;
		
		return surface_getpixel(_surf, _pos[0], _pos[1]);
	}
}