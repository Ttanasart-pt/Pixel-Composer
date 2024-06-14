function Node_RM_Combine(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RM Combine";
	batch_output = true;
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 1] = nodeValue("Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Perspective", "Orthographic" ])
		.setVisible(false, false);
	
	inputs[| 2] = nodeValue("FOV", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 30)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 90, 1 ] });
	
	inputs[| 3] = nodeValue("Ortho Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 5.)
	
	inputs[| 4] = nodeValue("View Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 3, 6 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue("Depth", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 6] = nodeValue("Draw BG", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 7] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 8] = nodeValue("Ambient Level", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 9] = nodeValue("Light Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ -.5, -.5, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 10] = nodeValue("Environment", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, false);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 11] = nodeValue("Shape 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.struct, {})
		.setVisible(true, true);
	
	inputs[| 12] = nodeValue("Shape 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.struct, {})
		.setVisible(true, true);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	outputs[| 0] = nodeValue("Surface Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Shape Data", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, noone);
	
	input_display_list = [ 0,
		["Camera", false], 1, 2, 3, 4, 5, 
		["Render", false], 6, 7, 8, 10, 9, 
		["Shapes", false], 11, 12, 
	]
	
	temp_surface = [ 0, 0 ];
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) {
		var _dim = _data[0];
		
		var _pro = _data[1];
		var _fov = _data[2];
		var _ort = _data[3];
		var _vrn = _data[4];
		var _dep = _data[5];
		
		var _bgd = _data[6];
		var _bgc = _data[7];
		var _amb = _data[8];
		var _lig = _data[9];
		var _env = _data[10];
		
		var _sh0 = _data[11];
		var _sh1 = _data[12];
		
		if(!is_instanceof(_sh0, RM_Object)) return [ _outSurf, noone ];
		if(!is_instanceof(_sh1, RM_Object)) return [ _outSurf, noone ];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++)
			temp_surface[i] = surface_verify(temp_surface[i], 8192, 8192);
		
		var tx = 1024;
		surface_set_shader(temp_surface[0]);
			draw_surface_stretched_safe(_env, tx * 0, tx * 0, tx, tx);
		surface_reset_shader();
		
		var object = new RM_Operation("combine", _sh0, _sh1);
		object.flatten();
		object.setTexture(temp_surface[1]);
		
		gpu_set_texfilter(true);
		surface_set_shader(_outSurf, sh_rm_primitive);
			
			shader_set_surface($"texture0", temp_surface[0]);
			
			shader_set_i("ortho",       _pro);
			shader_set_f("fov",         _fov);
			shader_set_f("orthoScale",  _ort);
			shader_set_f("viewRange",   _vrn);
			shader_set_f("depthInt",    _dep);
			
			shader_set_i("drawBg",  	   _bgd);
			shader_set_color("background", _bgc);
			shader_set_f("ambientIntns",   _amb);
			shader_set_f("lightPosition",  _lig);
			
			shader_set_i("useEnv",      is_surface(_env));
			
			object.apply();
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		gpu_set_texfilter(false);
		
		return [ _outSurf, object ]; 
	}
}