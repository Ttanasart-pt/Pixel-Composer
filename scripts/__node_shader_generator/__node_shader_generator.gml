function Node_Shader_Generator(_x, _y, _group = noone) : Node_Shader(_x, _y, _group) constructor {
	name = "";
	shader_interpolate = false;
	
	newInput(0, nodeValue_Dimension()).setShaderProp("dimension");
	
	attribute_surface_depth();
	
	static generateShader = function(_outSurf, _data) {
		var _dim = _data[0];
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, shader);
			gpu_set_tex_filter(shader_interpolate);
			if(input_uvmap_index != -1)
				shader_set_uv(_data[input_uvmap_index], _data[input_uvmix_index]);
			setShader(_data);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		if(input_mask_index) _outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
	
	static onProcessData = function(_outSurf, _data, _array_index) {}
	
	static processData = function(_outSurf, _data, _array_index) {
		onProcessData(_outSurf, _data, _array_index);
		return generateShader(_outSurf, _data);
	}
	
}

/*
function Node_RENAME(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "RENAME";
	shader = sh_;
	
	////- =Output
	newInput( 1, nodeValue_Surface( "UV Map"     ));
	newInput( 2, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	
	////- =Shader
	// 4
	
	input_display_list = [
		[ "Output",     true ],  0,  1,  2,  3, 
		[ "Shader",    false ],  
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
}
*/