function Node_RM_Render(_x, _y, _group = noone) : Node_RM(_x, _y, _group) constructor {
	name  = "RM Render";
	
	inputs[| 0] = nodeValue_Dimension(self);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 1] = nodeValue_Enum_Button("Projection", self,  0, [ "Perspective", "Orthographic" ]);
	
	inputs[| 2] = nodeValue("FOV", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 30)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 90, 1 ] });
	
	inputs[| 3] = nodeValue("Ortho Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 5.)
	
	inputs[| 4] = nodeValue("View Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 3, 6 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue("Depth", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 6] = nodeValue("Draw BG", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 7] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 8] = nodeValue("Ambient Level", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 9] = nodeValue("Light Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ -.4, -.5, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 10] = nodeValue_Surface("Environment", self);
	
	inputs[| 11] = nodeValue("Camera Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 30, 45, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 12] = nodeValue("Camera Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 13] = nodeValue("SDF Object", self, JUNCTION_CONNECT.input, VALUE_TYPE.sdf, {})
		.setVisible(true, true);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 14] = nodeValue("Env Interpolation", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Surface Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0, 13, 
		["Camera",  false], 11, 12, 1, 2, 3, 4, 5, 
		["Render",  false], 6, 7, 8, 10, 14, 9, 
	]
	
	temp_surface = [ 0, 0 ];
	environ = new RM_Environment();
	object  = noone;
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {}
	
	static step = function() {
		var _pro = getSingleValue( 1);
		
		inputs[| 3].setVisible(_pro == 1);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) {
		var _dim = _data[0];
		
		var _pro = _data[1];
		var _fov = _data[2];
		var _ort = _data[3];
		var _vrn = _data[4];
		var _dep = _data[5];
		
		var _bgd = _data[6];
		var _enc = _data[7];
		var _amb = _data[8];
		var _lig = _data[9];
		var _env = _data[10];
		var _crt = _data[11];
		var _csa = _data[12];
		
		var _shp  = _data[13];
		var _eint = _data[14];
		
		if(!is_instanceof(_shp, RM_Object)) return _outSurf;
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++)
			temp_surface[i] = surface_verify(temp_surface[i], 8192, 8192);
		
		var tx = 1024;
		surface_set_shader(temp_surface[0]);
			gpu_set_tex_filter(_eint);
			draw_surface_stretched_safe(_env, tx * 0, tx * 0, tx, tx);
			gpu_set_tex_filter(false);
		surface_reset_shader();
		
 		object = _shp;
		object.flatten();
		object.setTexture(temp_surface[1]);
		
		environ.surface   = temp_surface[0];
		environ.bgEnv     = _env;
		environ.envFilter = _eint;
		
		environ.projection = _pro;
		environ.fov        = _fov;
		environ.orthoScale = _ort;
		environ.viewRange  = _vrn;
		environ.depthInt   = _dep;
		
		environ.bgColor    = _enc;
		environ.bgDraw     = _bgd;
		environ.ambInten   = _amb;
		environ.light      = _lig;
		
		gpu_set_texfilter(true);
		surface_set_shader(_outSurf, sh_rm_primitive);
			
			shader_set_f("camRotation", _crt);
			shader_set_f("camScale",    _csa);
			shader_set_f("camRatio",    _dim[0] / _dim[1]);
			
			environ.apply();
			object.apply();
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		gpu_set_texfilter(false);
		
		return _outSurf; 
	}
}