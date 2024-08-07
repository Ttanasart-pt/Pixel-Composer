function Node_RM_Combine(_x, _y, _group = noone) : Node_RM(_x, _y, _group) constructor {
	name  = "RM Combine";
	
	inputs[| 0] = nodeValue_Dimension(self);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 1] = nodeValue_Enum_Button("Projection", self,  0, [ "Perspective", "Orthographic" ]);
	
	inputs[| 2] = nodeValue_Float("FOV", self, 30)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 90, 1 ] });
	
	inputs[| 3] = nodeValue_Float("Ortho Scale", self, 5.)
	
	inputs[| 4] = nodeValue_Vector("View Range", self, [ 3, 6 ]);
	
	inputs[| 5] = nodeValue_Float("Depth", self, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 6] = nodeValue_Bool("Draw BG", self, false);
	
	inputs[| 7] = nodeValue_Color("Background", self, c_black);
	
	inputs[| 8] = nodeValue_Float("Ambient Level", self, 0.2)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 9] = nodeValue_Vector("Light Position", self, [ -.4, -.5, 1 ]);
	
	inputs[| 10] = nodeValue_Surface("Environment", self);
	
	inputs[| 11] = nodeValue_Vector("Camera Rotation", self, [ 30, 45, 0 ]);
	
	inputs[| 12] = nodeValue_Float("Camera Scale", self, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 13] = nodeValue_SDF("Shape 1", self, {})
		.setVisible(true, true);
	
	inputs[| 14] = nodeValue_SDF("Shape 2", self, {})
		.setVisible(true, true);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 15] = nodeValue_Enum_Scroll("Type", self,  0, [ "Place", "Union", "Subtract", "Intersect" ]);
	
	inputs[| 16] = nodeValue_Float("Merge", self, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 17] = nodeValue_Bool("Render", self, true);
	
	inputs[| 18] = nodeValue_Bool("Env Interpolation", self, false);
	
	outputs[| 0] = nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue_Output("Shape Data", self, VALUE_TYPE.sdf, noone);
	
	input_display_list = [ 0,
		["Combine", false], 15, 16, 13, 14, 
		["Camera",  false], 11, 12, 1, 2, 3, 4, 5, 
		["Render",  false, 17], 6, 7, 8, 10, 18, 9, 
	]
	
	temp_surface = [ 0, 0 ];
	environ = new RM_Environment();
	object  = noone;
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {}
	
	static step = function() {
		var _type = getSingleValue(15);
		var _ren  = getSingleValue(17);
		
		inputs[| 16].setVisible(_type > 0);
		
		outputs[| 0].setVisible(_ren, _ren);
		
	}
	static processData = function(_outData, _data, _output_index, _array_index = 0) {
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
		
		if(!is_instanceof(_sh0, RM_Object)) return [ _outSurf, noone ];
		if(!is_instanceof(_sh1, RM_Object)) return [ _outSurf, noone ];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
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