function Node_Surface_data(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name	= "Surface data";
	color	= COLORS.node_blend_number;
	previewable = false;
	
	inputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	outputs[| 1] = nodeValue("Array length", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	
	w = 96;
	
	static update = function(frame = CURRENT_FRAME) {
		var _insurf	= getInputData(0);
		if(is_array(_insurf)) {
			var len = array_length(_insurf);
			var _dim = array_create(len);
			
			for( var i = 0; i < len; i++ ) {
				_dim[i][0] = surface_get_width_safe(_insurf[i]);
				_dim[i][1] = surface_get_height_safe(_insurf[i]);
			}
			
			outputs[| 0].setValue(_dim);
			outputs[| 1].setValue(len);
			return;
		}
		
		if(!_insurf || !surface_exists(_insurf)) return;
		
		outputs[| 0].setValue([ surface_get_width_safe(_insurf), surface_get_height_safe(_insurf) ]);
	}
}