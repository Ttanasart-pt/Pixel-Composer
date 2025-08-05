#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blend_Edge", "Width > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER);  });
		addHotkey("Node_Blend_Edge", "Types > Toggle",            "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 3); });
	});
#endregion

function Node_Blend_Edge(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blend Edge";
	
	newActiveInput(3);
	newInput(4, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	
	////- =Blend
	newInput(2, nodeValue_Enum_Button( "Types",       0, [ "Both", "Horizontal", "Vertical" ]));
	newInput(1, nodeValue_Slider(      "Width",      .1 )).setHotkey("W").setMappable(5);
	newInput(6, nodeValue_Slider(      "Blending",    1 )).setHotkey("B");
	newInput(7, nodeValue_Slider(      "Smoothness",  0 )).setHotkey("S");
	
	// input 8
		
	input_display_list = [ 3, 4, 
		["Surfaces", true], 0, 
		["Blend",	false], 2, 1, 5, 6, 7, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	temp_surface = array_create(1);
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy - ui(24), _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		InputDrawOverlay(inputs[6].drawOverlay(w_hoverable, active, _cx, _cy,          _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		InputDrawOverlay(inputs[7].drawOverlay(w_hoverable, active, _cx, _cy + ui(24), _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _sw = surface_get_width_safe(_data[0]);
		var _sh = surface_get_height_safe(_data[0]);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
		
		var _edg = _data[2];
		
		if(_edg == 0) {
			surface_set_shader(temp_surface[0], sh_blend_edge);
				shader_set_f("dimension", _sw, _sh);
				shader_set_f_map("width", _data[1], _data[5], inputs[1]);
				shader_set_i("edge"     , 0);
				shader_set_f("blend"    , clamp(_data[6], 0.001, 0.999));
				shader_set_f("smooth"   , _data[7]);
				
				draw_surface_safe(_data[0]);
			surface_reset_shader();
			
			surface_set_shader(_outSurf, sh_blend_edge);
				shader_set_i("edge"     , 1);
				
				draw_surface_safe(temp_surface[0]);
			surface_reset_shader();
			
		} else {
			surface_set_shader(_outSurf, sh_blend_edge);
				shader_set_f("dimension", _sw, _sh);
				shader_set_f_map("width", _data[1], _data[5], inputs[1]);
				shader_set_i("edge"     , _edg - 1);
				shader_set_f("blend"    , clamp(_data[6], 0.001, 0.999));
				
				draw_surface_safe(_data[0]);
			surface_reset_shader();
			
		}
		
		return _outSurf;
	}
}