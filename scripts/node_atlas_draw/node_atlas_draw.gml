function Node_Atlas_Draw(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Atlas";
	previewable = true;
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Atlas("Atlas", self))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newInput(2, nodeValue_Bool("Combine", self, true))
		.rejectArray()
	
	newOutput(0, nodeValue_Output("Surface", self, VALUE_TYPE.surface, noone));
	
	attribute_interpolation(true);
	
	input_display_list = [
		0, 1, 2, 
	];
	
	static preGetInputs = function() {
		var _comb = getSingleValue(2);
		inputs[1].setArrayDepth(_comb);
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) {
		var dim = _data[0];
		var atl = _data[1];
		
		surface_set_shader(_outSurf);
		if(!is_array(atl)) {
			if(is(atl, Atlas)) { shader_set_interpolation(atl.getSurface()); atl.draw(); }
			
		} else {
			for( var i = 0, n = array_length(atl); i < n; i++ )
				if(is(atl[i], Atlas)) { shader_set_interpolation(atl[i].getSurface()); atl[i].draw(); }
		}
		surface_reset_shader();
		
		return _outSurf;
	}
}