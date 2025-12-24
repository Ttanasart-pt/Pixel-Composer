function Node_Atlas_Draw(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Atlas";
	previewable = true;
	
	////- =Atlases
	
	newInput(1, nodeValue_Atlas()).setArrayDepth(1).setVisible(true, true);
	newInput(2, nodeValue_Bool( "Combine",            true )).rejectArray();
	
	////- =Output
	
	newInput(3, nodeValue_Bool(    "Use Base Dimension", true     )).rejectArray();
	newInput(0, nodeValue_Dimension());
	newInput(4, nodeValue_Padding( "Padding",           [0,0,0,0] )).rejectArray();
	
	// input 5
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		["Atlases",  false], 1, 2, 
		["Output",   false], 3, 0, 4, 
	];
	
	////- Nodes
	
	attribute_interpolation(true);
	
	temp_surface = [0,0,0];
	
	static preGetInputs = function() {
		var _comb = getInputSingle(2);
		inputs[1].setArrayDepth(_comb);
	}
	
	draw_transforms = [0,0,1,1,0];
	static drawOverlayTransform = function(_n) /*=>*/ {return draw_transforms};
	
	static getDimension = function(arr = 0) { return [1,1]; } 
	
	static processData = function(_outSurf, _data, _array_index = 0) {
		var atl = _data[1];
		
		var bas = _data[3];
		var dim = _data[0];
		var pad = _data[4];
		
		inputs[0].setVisible(!bas);
		
		if(!is_array(atl)) atl = [atl];
		
		var _dim = dim; 
		
		if(bas) {
			var _a = array_safe_get_fast(atl, 0);
			if(is(_a, Atlas)) 
				_dim = surface_get_dimension(_a.oriSurf);
		} 
		
		_dim[0] += pad[0] + pad[2];
		_dim[1] += pad[1] + pad[3];
		
		draw_transforms[0] = pad[2];
		draw_transforms[1] = pad[1];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
			surface_clear(temp_surface[i]);
		}
		
		blend_temp_surface = temp_surface[2];
		var bg = 0;
		
		for( var i = 0, n = array_length(atl); i < n; i++ ) {
			var _a = atl[i];
			if(!is(_a, Atlas)) continue;
			
			surface_set_shader(temp_surface[bg], sh_sample, true, BLEND.over);
				try { draw_surface_blend_ext(temp_surface[!bg], _a, pad[2], pad[1]); }
				catch(e) { noti_warning(e, noone, self); }
			surface_reset_shader();
			
			bg = !bg;
		}
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[!bg]);
		surface_reset_shader();
		
		return _outSurf;
	}
}