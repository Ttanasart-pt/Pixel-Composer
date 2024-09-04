function Node_Surface_data(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name	= "Surface data";
	color	= COLORS.node_blend_number;
	
	newInput(0, nodeValue_Surface("Surface", self));
	
	newOutput(0, nodeValue_Output("Dimension", self, VALUE_TYPE.integer, [ 1, 1 ]))
		.setDisplay(VALUE_DISPLAY.vector);
		
	newOutput(1, nodeValue_Output("Array length", self, VALUE_TYPE.integer, 0));
	
	
	setDimension(96, 48);
	
	static update = function(frame = CURRENT_FRAME) {
		var _insurf	= getInputData(0);
		if(is_array(_insurf)) {
			var len = array_length(_insurf);
			var _dim = array_create(len);
			
			for( var i = 0; i < len; i++ ) {
				_dim[i][0] = surface_get_width_safe(_insurf[i]);
				_dim[i][1] = surface_get_height_safe(_insurf[i]);
			}
			
			outputs[0].setValue(_dim);
			outputs[1].setValue(len);
			return;
		}
		
		if(!_insurf || !surface_exists(_insurf)) return;
		
		outputs[0].setValue([ surface_get_width_safe(_insurf), surface_get_height_safe(_insurf) ]);
	}
}