#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Bloom", "Size > Set", KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Bloom(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Bloom";
	
	newActiveInput(7);
	newInput(8, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- Surfaces
	
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(5, nodeValue_Surface( "Mask" ));
	newInput(6, nodeValue_Slider(  "Mix", 1));
	__init_mask_modifier(5, 9); // inputs 9, 10
	
	////- Bloom
	
	newInput(1, nodeValue_Slider(  "Size",       3,   [1, 32, 0.1] )).setTooltip("Bloom blur radius.");
	newInput(2, nodeValue_Slider(  "Tolerance",  .50               )).setTooltip("How bright a pixel should be to start blooming.");
	newInput(3, nodeValue_Slider(  "Strength",   .25, [0, 2, 0.01] )).setTooltip("Blend intensity.");
	newInput(4, nodeValue_Surface( "Bloom mask"));
	
	////- Blur
	
	newInput(13, nodeValue_Enum_Scroll( "Type",          0, [ "Gaussian", "Zoom", "Directional" ]));
	newInput(11, nodeValue_Slider(      "Aspect Ratio",  1 ));
	newInput(12, nodeValue_Rotation(    "Direction",     0 ));
	newInput(14, nodeValue_Vec2(        "Zoom Origin", [.5,.5] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	
	////- Blend
	
	newInput(15, nodeValue_Color(  "Blend",      ca_white));
	newInput(16, nodeValue_Slider( "Saturation", 1, [ 0, 2, 0.01 ] ));
	
	input_display_list = [ 7, 8, 
		["Surfaces",  true],  0,  5,  6,  9, 10, 
		["Bloom",    false],  1,  2,  3,  4,
		["Blur",     false], 13, 11, 12, 14, 
		["Blend",    false], 15, 16, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Bloom Mask", VALUE_TYPE.surface, noone));
	
	temp_surface = [ noone ];
	
	attribute_surface_depth();
	surface_blur_init();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _typ = getSingleValue(13);
		var _dim = getDimension();
		
		var cx = _x + _dim[0] / 2 * _s;
		var cy = _y + _dim[1] / 2 * _s;
		
		if(_typ == 1) InputDrawOverlay(inputs[14].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		if(_typ == 2) InputDrawOverlay(inputs[12].drawOverlay(w_hoverable, active, cx, cy, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index) {
		var _surf  = _data[0];
		var _size  = _data[1];
		var _tole  = _data[2];
		var _stre  = _data[3];
		var _mask  = _data[4];
		
		var _type  = _data[13];
		var _ratio = _data[11];
		var _angle = _data[12];
		var _zoom  = _data[14];
		
		var _blnd  = _data[15];
		var _satr  = _data[16];
		
		inputs[11].setVisible(_type == 0);
		inputs[12].setVisible(_type == 0 || _type == 2);
		inputs[14].setVisible(_type == 1);
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		temp_surface[0] = surface_verify(temp_surface[0], _sw, _sh);	
		var _outSurf    = surface_verify(_outData[0], _sw, _sh);
		var _maskSurf   = surface_verify(_outData[1], _sw, _sh);
		
		surface_set_shader(temp_surface[0], sh_bloom_pass);
			draw_clear_alpha(c_black, 1);
			shader_set_f("size",      _size);
			shader_set_f("tolerance", _tole);
				
			shader_set_i("useMask",    is_surface(_mask));
			shader_set_surface("mask", _mask);
				
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		var pass1blur;
		
		     if(_type == 0) pass1blur = surface_apply_gaussian( temp_surface[0], _size, true, c_black, 1, noone, false, _ratio, _angle);
		else if(_type == 1) pass1blur = surface_apply_blur_zoom(__blur_pass[0], new blur_zoom_args(temp_surface[0], _size, _zoom[0], _zoom[1], 2, 1));
		else if(_type == 2) pass1blur = surface_apply_blur_directional(__blur_pass[0], new blur_directional_args(temp_surface[0], _size, _angle).setFadeDistance(true));
		
		surface_set_shader(temp_surface[0], sh_bloom_blend);
			shader_set_c("blend",      _blnd);
			shader_set_f("saturation", _satr);
			
			draw_surface_safe(pass1blur);
		surface_reset_shader();
		
		surface_set_shader(_outSurf, sh_blend_add_alpha_adj);
			shader_set_surface("fore", temp_surface[0]);
			shader_set_f("opacity",	   _stre);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		surface_set_shader(_maskSurf, noone);
			draw_surface_safe(temp_surface[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[5], _data[6]);
		_outSurf = channel_apply(_surf, _outSurf, _data[8]);
		
		return [ _outSurf, _maskSurf ];
	}
}