function Node_RM_Combine(_x, _y, _group = noone) : Node_RM(_x, _y, _group) constructor {
	name  = "RM Combine";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 1] = nodeValue("Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Perspective", "Orthographic" ]);
	
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
	
	inputs[| 11] = nodeValue("Camera Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 30, 45, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 12] = nodeValue("Camera Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 13] = nodeValue("Shape 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.sdf, {})
		.setVisible(true, true);
	
	inputs[| 14] = nodeValue("Shape 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.sdf, {})
		.setVisible(true, true);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 15] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Place", "Union", "Subtract", "Intersect" ]);
	
	inputs[| 16] = nodeValue("Merge", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 17] = nodeValue("Render", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	outputs[| 0] = nodeValue("Surface Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Shape Data", self, JUNCTION_CONNECT.output, VALUE_TYPE.sdf, noone);
	
	input_display_list = [ 0,
		["Combine", false], 15, 16, 13, 14, 
		["Camera",  false], 11, 12, 1, 2, 3, 4, 5, 
		["Render",  false, 17], 6, 7, 8, 10, 9, 
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
		
		var _outSurf = _outData[0];
		
		if(!is_instanceof(_sh0, RM_Object)) return [ _outSurf, noone ];
		if(!is_instanceof(_sh1, RM_Object)) return [ _outSurf, noone ];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++)
			temp_surface[i] = surface_verify(temp_surface[i], 8192, 8192);
		
		var tx = 1024;
		surface_set_shader(temp_surface[0]);
			draw_surface_stretched_safe(_env, tx * 0, tx * 0, tx, tx);
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
		
		environ.surface = temp_surface[0];
		environ.bgEnv   = _env;
		
		environ.projection = _ort;
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