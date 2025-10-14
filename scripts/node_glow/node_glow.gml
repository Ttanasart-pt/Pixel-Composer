#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Glow", "Size > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[2].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Glow", "Mode > Toggle",            "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[10].setValue((_n.inputs[10].getValue() + 1) % 2); });
		addHotkey("Node_Glow", "Side > Toggle",            "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[12].setValue((_n.inputs[12].getValue() + 1) % 2); });
		addHotkey("Node_Glow", "Draw Original > Toggle",   "O", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[11].setValue((_n.inputs[11].getValue() + 1) % 2); });
	});
#endregion

function Node_Glow(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Glow";
	
	newActiveInput(7);
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(5, nodeValue_Surface( "Mask"       ));
	newInput(6, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(5, 8); // inputs 8, 9, 
	
	////- =Glow
	newInput(10, nodeValue_Enum_Button( "Mode",  0,  [ "Greyscale", "Alpha" ] ));
	newInput(12, nodeValue_Enum_Button( "Side",  0,  [ "Outer", "Inner" ] ));
	newInput( 1, nodeValue_Slider( "Border",     0,  [0,  4, .1 ] )).setHotkey("B");
	newInput( 2, nodeValue_Slider( "Size",       3,  [1, 16, .1 ] )).setHotkey("S").setMappable(16);
	newInput( 3, nodeValue_Slider( "Strength",   1,  [0,  4, .01] )).setHotkey("T").setMappable(17);
	newInput(15, nodeValue_Curve(  "Strength Curve", CURVE_DEF_01 ));
	
	////- =Render
	newInput(13, nodeValue_Enum_Button( "Blend Mode",  3, [ "Normal", "Replace", -1, "Lighten", "Screen", -1, "Darken", "Multiply" ]));
	newInput( 4, nodeValue_Color( "Color",          ca_white ));
	newInput(14, nodeValue_Bool(  "Pixel Distance", true     ));
	newInput(11, nodeValue_Bool(  "Draw Original",  true     ));
	// input 18
		
	input_display_list = [ 7, 
		["Surfaces", true], 0, 5, 6, 8, 9, 
		["Glow",	false], 10, 12, 2, 16, 3, 17, 15, 
		["Render",	false], 13, 4, 14, 11, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny,   0, _dim[0] / 16));
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny,  90, _dim[1] /  2));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf     = _data[ 0];
		
		var _mode     = _data[10];
		var _side     = _data[12];
		var _border   = _data[ 1];
		var _size     = _data[ 2];
		var _strn = _data[ 3];
		var _fallCur  = _data[15];
		
		var _blend    = _data[13];
		var _color    = _data[ 4];
		var _render   = _data[11];
		var _pxDist   = _data[14];
		
		surface_set_shader(_outSurf, sh_glow);
			shader_set_dim("dimension", _surf);
			
			shader_set_i("mode",      _mode);
			shader_set_i("side",      _side);
			shader_set_f("border",    _border);
			shader_set_f_map("size",      _size, _data[16], inputs[2] );
			shader_set_f_map("strength",  _strn, _data[17], inputs[3] );
			shader_set_curve("falloff", _fallCur);
			
			shader_set_i("blend",     _blend);
			shader_set_color("color", _color);
			shader_set_i("render",    _render);
			shader_set_i("pixelDist", _pxDist);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[5], _data[6]);
		
		return _outSurf;
	}
}