function Node_RM_Render(_x, _y, _group = noone) : Node_RM(_x, _y, _group) constructor {
	name  = "RM Render";
	
	newInput(0, nodeValue_Dimension());
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(1, nodeValue_Enum_Button("Projection",  0, [ "Perspective", "Orthographic" ]));
	
	newInput(2, nodeValue_Slider("FOV", 30, [ 0, 90, 1 ] ));
	
	newInput(3, nodeValue_Float("Ortho Scale", 5.))
	
	newInput(4, nodeValue_Vec2("View Range", [ 3, 6 ]));
	
	newInput(5, nodeValue_Slider("Depth", 0));
	
	newInput(6, nodeValue_Bool("Draw BG", false));
	
	newInput(7, nodeValue_Color("Background", ca_black));
	
	newInput(8, nodeValue_Slider("Ambient Level", 0.2));
	
	newInput(9, nodeValue_Vec3("Light Position", [ -.4, -.5, 1 ]));
	
	newInput(10, nodeValue_Surface("Environment"));
	
	newInput(11, nodeValue_Vec3("Camera Rotation", [ 30, 45, 0 ]));
	
	newInput(12, nodeValue_Slider("Camera Scale", 1, [ 0, 4, 0.01 ] ));
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(13, nodeValue_SDF("SDF Object"))
		.setVisible(true, true);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(14, nodeValue_Bool("Env Interpolation", false));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 13, 
		["Camera",  false], 11, 12, 1, 2, 3, 4, 5, 
		["Render",  false], 6, 7, 8, 10, 14, 9, 
	]
	
	temp_surface = [ noone, noone ];
	environ = new RM_Environment();
	object  = noone;
	
	static drawOverlay3D = function(active, _mx, _my, _params) {}
	
	static step = function() {
		var _pro = getInputSingle( 1);
		
		inputs[3].setVisible(_pro == 1);
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) {
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