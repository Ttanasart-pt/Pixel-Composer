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
	filtering_vl      = false;
	filter_button     = new buttonAnchor(noone, function(i) /*=>*/ {
		if(mouse_press(mb_left)) 
			filtering_vl = !attributes.filter[i];
		attributes.filter[i] = filtering_vl;
		triggerRender();
	});
	
	newActiveInput(11);
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 9, nodeValue_Surface( "Mask"       ));
	newInput(10, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(9, 13);
	
	////- =Outline
	newInput(18, nodeValue_Enum_Scroll( "Profile",     0, [ "Circle", "Square", "Diamond" ] ));
	newInput( 1, nodeValue_Float(       "Width",       0 )).setHotkey("S").setDisplay(VALUE_DISPLAY._default, { front_button : filter_button }).setValidator(VV_min(0)).setMappable(15);
	newInput( 5, nodeValue_Enum_Button( "Position",    1, ["Inside", "Outside"] ));
	newInput( 8, nodeValue_Int(         "Start",       0, "Shift outline inside, outside the shape." )).setMappable(17);
	newInput(12, nodeValue_Bool(        "Crop border", false ));
	newInput(19, nodeValue_Slider(      "Threshold",   1     ));
	
	////- =Render
	newInput( 2, nodeValue_Color( "Color",         ca_white ));
	newInput( 6, nodeValue_Bool(  "Anti-aliasing", 0        ));
	newInput(20, nodeValue_Bool(  "High res",      0        ));
	
	////- =Blend
	newInput( 3, nodeValue_Bool(        "Blend",           false, "Blend outline color with the original color." ));
	newInput( 4, nodeValue_Slider(      "Blend alpha",     1 )).setMappable(16);
	newInput( 7, nodeValue_Enum_Scroll( "Oversample mode", 0, [ "Empty", "Clamp", "Repeat" ] ));
	
	//// inputs 21
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Outline",     VALUE_TYPE.surface, noone));
	
	input_display_list = [ 11, 
		["Surfaces", true],    0, 9, 10, 13, 14, 
		["Outline",	false],    18, 1, 15, 5, 8, 17, 12, 19, 
		["Render",	false],    2, 6, 20, 
		["Blend",	 true, 3], 4, 16,
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index) {
		var surf = _data[ 0];
		var colr = _data[ 2];
		var blnd = _data[ 3];
		var side = _data[ 5];
		var alis = _data[ 6];
		var crop = _data[12];
		var prof = _data[18];
		var thrs = _data[19];
		var hres = _data[20];
		
		inputs[1].setType(alis? VALUE_TYPE.float : VALUE_TYPE.integer);
		
		filter_button.index = attributes.filter;
		
		var ww   = surface_get_width_safe(surf);
		var hh   = surface_get_height_safe(surf);
		var samp = getAttribute("oversample");
		
		surface_set_shader(_outData, sh_outline);
			shader_set_f("dimension",       ww, hh);
			shader_set_f_map("borderSize",  _data[1], _data[15], inputs[1]);
			shader_set_f_map("borderStart", _data[8], _data[17], inputs[8]);
			shader_set_f_map("blend_alpha", _data[4], _data[16], inputs[4]);
			shader_set_i("filter",          attributes.filter);
			
			shader_set_i("highRes",         hres);
			shader_set_c("borderColor",     colr);
			shader_set_i("profile",         prof);
			shader_set_i("side",            side);
			shader_set_i("is_aa",           alis);
			shader_set_i("is_blend",        blnd);
			shader_set_i("sampleMode",      samp);
			shader_set_i("crop_border",     crop);
			shader_set_f("alphaThers",      thrs);
			
			draw_surface_safe(surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		
		_outData[0] = mask_apply(surf, _outData[0], _data[9], _data[10]);
		_outData[1] = mask_apply(surf, _outData[1], _data[9], _data[10]);
		
		return _outData;
	}
}