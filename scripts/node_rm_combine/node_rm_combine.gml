function Node_RM_Combine(_x, _y, _group = noone) : Node_RM(_x, _y, _group) constructor {
	name  = "RM Combine";
	
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
	
	newInput(13, nodeValue_SDF("Shape 1"))
		.setVisible(true, true);
	
	newInput(14, nodeValue_SDF("Shape 2"))
		.setVisible(true, true);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(15, nodeValue_Enum_Scroll("Type",  0, [ "Place", "Union", "Subtract", "Intersect" ]));
	
	newInput(16, nodeValue_Slider("Merge", 0.1));
	
	newInput(17, nodeValue_Bool("Render", true));
	
	newInput(18, nodeValue_Bool("Env Interpolation", false));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Shape Data", VALUE_TYPE.sdf, noone));
	
	input_display_list = [ 0,
		["Combine", false], 15, 16, 13, 14, 
		["Camera",  false], 11, 12, 1, 2, 3, 4, 5, 
		["Render",  false, 17], 6, 7, 8, 10, 18, 9, 
	]
	
	temp_surface = [ noone, noone ];
	environ = new RM_Environment();
	object  = noone;
	
	static drawOverlay3D = function(active, _mx, _my, _snx, _sny, _params) {}
	
	static step = function() {
		var _type = getInputSingle(15);
		var _ren  = getInputSingle(17);
		
		inputs[16].setVisible(_type > 0);
		
		outputs[0].setVisible(_ren);
		
	}
	static processData = function(_outData, _data, _array_index = 0) {
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
		
		var _sh0 = _data[13];
		var _sh1 = _data[14];
		var _typ = _data[15];
		var _mer = _data[16];
		var _ren = _data[17];
		
		var _eint = _data[18];
		
		var _outSurf = _outData[0];
		    _outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		if(!is(_sh0, RM_Object) || !is(_sh1, RM_Object)) {
			surface_clear(_outSurf);
			return [ _outSurf, noone ];
		}
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++)
			temp_surface[i] = surface_verify(temp_surface[i], 8192, 8192);
		
		var tx = 1024;
		surface_set_shader(temp_surface[0]);
			gpu_set_tex_filter(_eint);
			draw_surface_stretched_safe(_env, tx * 0, tx * 0, tx, tx);
			gpu_set_tex_filter(false);
		surface_reset_shader();
		
		switch(_typ) {
			case 0 : object = new RM_Operation("combine",   _sh0, _sh1); break;
			case 1 : object = new RM_Operation("union",     _sh0, _sh1); break;
			case 2 : object = new RM_Operation("subtract",  _sh0, _sh1); break;
			case 3 : object = new RM_Operation("intersect", _sh0, _sh1); break;
 		}
 		
 		object.merge = _mer;
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
		
		if(_ren) {
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
		}
		
		return [ _outSurf, object ]; 
	}
}