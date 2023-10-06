function Node_Atlas_Draw(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Draw Atlas";
	previewable = true;
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Atlas", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_interpolation(true);
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var dim = getInputData(0);
		var atl = getInputData(1);
		
		if(atl == noone) return;
		if(is_array(atl) && array_length(atl) == 0) return;
		
		if(!is_array(atl))
			atl = [ atl ];
		
		var outSurf = outputs[| 0].getValue();
		outSurf = surface_verify(outSurf, dim[0], dim[1]);
		outputs[| 0].setValue(outSurf);
		
		surface_set_shader(outSurf,,, BLEND.alpha);
			for( var i = 0, n = array_length(atl); i < n; i++ ) {
				shader_set_interpolation(atl[i].getSurface())
				atl[i].draw();
			}
		surface_reset_shader();
	}
}