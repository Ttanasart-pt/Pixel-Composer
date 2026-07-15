#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Outline", "Width > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Outline", "Position > Toggle",         "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 5].setValue((_n.inputs[ 5].getValue() + 1) % 2); });
		addHotkey("Node_Outline", "Blend > Toggle",            "B", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 3].setValue((_n.inputs[ 3].getValue() + 1) % 2); });
		addHotkey("Node_Outline", "Profile > Toggle",          "P", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[18].setValue((_n.inputs[18].getValue() + 1) % 3); });
		addHotkey("Node_Outline", "Anti-aliasing > Toggle",    "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 6].setValue((_n.inputs[ 6].getValue() + 1) % 2); });
	});
#endregion

function Node_Outline(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Outline";
	
	attributes.filter = array_create(9, 1);
	filtering_vl      = undefined;
	filter_button     = new buttonAnchor(noone, function(i) /*=>*/ {
		if(mouse_lpress()) 
			filtering_vl = !attributes.filter[i];
		attributes.filter[i] = filtering_vl;
		triggerRender();
	});
	
	newActiveInput(11);
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(21, nodeValue_Surface( "Texture"    ));
	newInput( 9, nodeValue_Surface( "Mask"       ));
	newInput(10, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(9, 13);
	
	////- =Outline
	newInput( 5, nodeValue_EScroll( "Position",    1, [ 
		new scrollItem("Inside",  s_node_outline_position, 0), 
		new scrollItem("Outside", s_node_outline_position, 1), 
		new scrollItem("Middle",  s_node_outline_position, 2) 
	] )).setPieMenu();
	
	newInput(18, nodeValue_EScroll( "Profile",     0, [ 
		new scrollItem("Circle",  s_node_shape_circle,    0), 
		new scrollItem("Square",  s_node_shape_rectangle, 0),
		new scrollItem("Diamond", s_node_shape_misc,      0), 
	]));
	
	newInput( 1, nodeValue_Float(   "Width",       0     )).setHotkey("S").setMappable(15).setValidator(VV_min(0)).setUnitSimple(false).setPieMenu();
	newInput( 8, nodeValue_Int(     "Start",       0, "Shift outline inside, outside the shape." )).setMappable(17).setPieMenu();
	newInput(12, nodeValue_Bool(    "Crop border", false ));
	newInput(19, nodeValue_Slider(  "Threshold",   1     ));
	
	////- =Render
	newInput( 2, nodeValue_Color(   "Color",         ca_white )).setHotkeyAuto("C").setPieMenu();
	newInput( 6, nodeValue_Bool(    "Anti-aliasing", 0        ));
	newInput(20, nodeValue_Bool(    "High res",      0        ));
	
	////- =Blend
	newInput( 3, nodeValue_Bool(    "Blend",           false, "Blend outline color with the original color." ));
	newInput(22, nodeValue_EScroll( "Blend Mode",      0, [ "Normal", "Multiply", "Screen", "Additive" ] ));
	newInput( 4, nodeValue_Slider(  "Blend alpha",     1 )).setMappable(16);
	newInput( 7, nodeValue_EScroll( "Oversample Mode", 0, [ "Empty", "Clamp", "Repeat" ] ));
	// 23
	
	newOutput( 0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput( 1, nodeValue_Output( "Outline",     VALUE_TYPE.surface, noone ));
	
	angle_filter = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var bs = ui(24);
		var _h = bs * 3 + ui(16);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		var _cx = _x + _w / 2;
		var _cy = _y + _h / 2;
		
		for( var i = 0; i < 3; i++ ) 
		for( var j = 0; j < 3; j++ ) {
			var ind = i * 3 + j;
			var bx  = _cx + (j - 1) * bs - bs / 2;
			var by  = _cy + (i - 1) * bs - bs / 2;
			
			if(ind == 4) continue;
			
			var _fil = attributes.filter[ind];
			var bc = _fil? COLORS._main_accent : COLORS._main_icon;
			
			var b = buttonInstant_Pad(THEME.button_def, bx + ui(2), by + ui(2), bs - ui(4), bs - ui(4), _m, 
				_hover, _focus, "", THEME.outline_angle_filter, ind, bc);
			
			if(b == 1 && filtering_vl != undefined && attributes.filter[ind] != filtering_vl) {
				attributes.filter[ind] = filtering_vl;
				triggerRender();
			}
			
			if(b == 2) filtering_vl = !_fil;
		}
		
		if(mouse_lrelease()) filtering_vl = undefined;
		
		return _h;
		
	}).setName(__txt("Directions")).setPadName();
	
	input_display_list = [ 11, 
		[ "Surfaces",  true    ],  0, 21,  9, 10, 13, 14, 
		[ "Outline",  false    ],  5, angle_filter,   18,  1, 15,  8, 17, 12, 19, 
		[ "Render",   false    ],  2,  6, 20, 
		[ "Blend",     true, 3 ], 22,  4, 16,
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		drawOverlayInput(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var surf = _data[ 0];
			var text = _data[21];
			
			var prof = _data[18];
			var side = _data[ 5];
			var crop = _data[12];
			var thrs = _data[19];
			
			var colr = _data[ 2];
			var alis = _data[ 6];
			var hres = _data[20];
			
			var blnd = _data[ 3];
			var bmod = _data[22];
		
			inputs[1].setType(alis? VALUE_TYPE.float : VALUE_TYPE.integer);
		#endregion
		
		filter_button.index = attributes.filter;
		
		var ww   = surface_get_width_safe(surf);
		var hh   = surface_get_height_safe(surf);
		var samp = getAttribute("oversample");
		
		surface_set_shader(_outData, sh_outline );
			shader_set_f( "dimension",   ww, hh );
			shader_set_m( "borderSize",  _data[1], _data[15], inputs[1] );
			shader_set_m( "borderStart", _data[8], _data[17], inputs[8] );
			shader_set_m( "blend_alpha", _data[4], _data[16], inputs[4] );
			shader_set_i( "filter",      attributes.filter );
			
			shader_set_i( "useTexture",  is_surface(text) );
			shader_set_s( "texture",     text );
			
			shader_set_i( "highRes",     hres );
			shader_set_c( "borderColor", colr );
			shader_set_i( "profile",     prof );
			shader_set_i( "side",        side ); 
			shader_set_i( "is_aa",       alis );
			shader_set_i( "sampleMode",  samp );
			shader_set_i( "crop_border", crop );
			shader_set_f( "alphaThers",  thrs );
			
			shader_set_i( "blendOrig",   blnd );
			shader_set_i( "blendMode",   bmod );
			
			draw_surface_safe(surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		
		_outData[0] = mask_apply_input(surf, _outData[0], _data[9], _data[10], inputs[9]);
		_outData[1] = mask_apply_input(surf, _outData[1], _data[9], _data[10], inputs[9]);
		
		return _outData;
	}
}