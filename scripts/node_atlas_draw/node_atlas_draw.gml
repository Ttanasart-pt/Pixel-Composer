function Node_Atlas_Draw(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Draw Atlas";
	previewable = true;
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Surface("Atlas", self))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Surface", self, VALUE_TYPE.surface, noone));
	
	attribute_interpolation(true);
	
	static update = function(frame = CURRENT_FRAME) {
		var dim = getInputData(0);
		var atl = getInputData(1);
		
		if(atl == noone) return;
		if(is_array(atl) && array_length(atl) == 0) return;
		
		if(!is_array(atl)) atl = [ atl ];
		
		var outSurf = outputs[0].getValue();
		outSurf = surface_verify(outSurf, dim[0], dim[1]);
		outputs[0].setValue(outSurf);
		
		surface_set_shader(outSurf,,, BLEND.alpha);
			for( var i = 0, n = array_length(atl); i < n; i++ ) {
				var _a = atl[i];
				if(!is_instanceof(_a, Atlas)) continue;
				
				shader_set_interpolation(_a.getSurface())
				_a.draw();
			}
		surface_reset_shader();
	}
}