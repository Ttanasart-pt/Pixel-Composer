#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Kuwahara", "Radius > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[2].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Kuwahara", "Types > Toggle",             "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 3); });
	});
#endregion

function Node_Kuwahara(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Kuwahara";
	
	newActiveInput(1);
	newInput( 5, nodeValue_Float(  "Unused",  8  ));
	newInput( 6, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(14, nodeValue_Surface( "UV Map"     ));
	newInput(15, nodeValue_Slider(  "UV Mix",  1 ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	newInput( 4, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(3, 7); // inputs 7, 8
	
	////- =Surfaces
	newInput( 9, nodeValue_Enum_Scroll( "Types",  0, [ "Basic", "Anisotropics", "Generalized" ]));
	newInput( 2, nodeValue_Int(         "Radius",         2  )).setMappable(16).setHotkey("R").setValidator(VV_min(1));
	newInput(10, nodeValue_Slider(      "Alpha",          1  ));
	newInput(11, nodeValue_Slider(      "Zero crossing", .58 ));
	newInput(12, nodeValue_Float(       "Hardness",       8  ));
	newInput(13, nodeValue_Float(       "Sharpness",      8  ));
	// input 17
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 6, 
		[ "Surfaces",  true ],  0, 14, 15,  3,  4,  7,  8, 
		[ "Effects",  false ],  9,  2, 16, 10, 11, 12, 13, 
	];
	
	temp_surface = array_create(4);
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _type = _data[9];
		var _dim  = surface_get_dimension(_surf);
		
		inputs[10].setVisible(_type == 1);
		inputs[11].setVisible(_type != 0);
		inputs[12].setVisible(_type != 0);
		inputs[13].setVisible(_type != 0);
		
		switch(_type) {
			case 0 : 
				surface_set_shader(_outSurf, sh_kuwahara);
					shader_set_interpolation(_surf);
					shader_set_uv(_data[14], _data[15]);
					
					shader_set_2("dimension",  _dim);
					shader_set_f_map("radius", _data[2], _data[16], inputs[2]);
					
					draw_surface_safe(_surf);
				surface_reset_shader();
				break;
			
			case 1 :
				for( var i = 0; i < 3; i++ ) temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
				
				surface_set_shader(temp_surface[0], sh_kuwahara_ani_pass1);
					shader_set_interpolation(_surf);
					shader_set_uv(_data[14], _data[15]);
					
					shader_set_2("dimension", _dim);
					
					draw_surface_safe(_surf);
				surface_reset_shader();
				
				surface_set_shader(temp_surface[1], sh_kuwahara_ani_pass2);
					shader_set_interpolation(_surf);
					shader_set_uv(_data[14], _data[15]);
					
					shader_set_2("dimension", _dim);
					
					draw_surface_safe(temp_surface[0]);
				surface_reset_shader();
				
				surface_set_shader(temp_surface[2], sh_kuwahara_ani_pass3);
					shader_set_interpolation(_surf);
					shader_set_uv(_data[14], _data[15]);
					
					shader_set_2("dimension", _dim);
					
					draw_surface_safe(temp_surface[1]);
				surface_reset_shader();
				
				surface_set_shader(_outSurf, sh_kuwahara_ani_pass4);
					shader_set_interpolation(_surf);
					shader_set_uv(_data[14], _data[15]);
					
					shader_set_surface("tfm", temp_surface[2]);
					shader_set_2("dimension", _dim);
					
					shader_set_f("alpha",        _data[10]);
					shader_set_f_map("radius",   _data[2], _data[16], inputs[2]);
					shader_set_f("zeroCrossing", _data[11]);
					shader_set_f("hardness",     _data[12]);
					shader_set_f("sharpness",    _data[13]);

					draw_surface_safe(_surf);
				surface_reset_shader();
				
				break;
			
			case 2 : 
				surface_set_shader(_outSurf, sh_kuwahara_gen);
					shader_set_interpolation(_surf);
					shader_set_uv(_data[14], _data[15]);
					
					shader_set_2("dimension", _dim);
					shader_set_f_map("radius",   _data[2], _data[16], inputs[2]);
					shader_set_f("zeroCrossing", _data[11]);
					shader_set_f("hardness",     _data[12]);
					shader_set_f("sharpness",    _data[13]);
					
					draw_surface_safe(_surf);
				surface_reset_shader();
				break;
		}
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}