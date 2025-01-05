function Node_Atlas_Draw(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Atlas";
	previewable = true;
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Atlas("Atlas", self))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Surface", self, VALUE_TYPE.surface, noone));
	
	attribute_interpolation(true);
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) {
		var dim = _data[0];
		var atl = _data[1];
		
		//_outSurf = surface_verify(_outSurf, dim[0], dim[1]);
		if(!is_array(atl)) atl = [ atl ];
		
		surface_set_shader(_outSurf);
			for( var i = 0, n = array_length(atl); i < n; i++ ) {
				var _a = atl[i];
				if(!is_instanceof(_a, Atlas)) continue;
				
				shader_set_interpolation(_a.getSurface())
				_a.draw();
			}
		surface_reset_shader();
		
		return _outSurf;
	}
}