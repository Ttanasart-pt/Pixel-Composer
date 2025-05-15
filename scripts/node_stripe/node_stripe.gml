#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Stripe", "Amount > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Stripe", "Type > Toggle",      "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue((_n.inputs[3].getValue() + 1) % 3); });
		addHotkey("Node_Stripe", "Coloring > Toggle",  "C", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[6].setValue((_n.inputs[6].getValue() + 1) % 3); });
		addHotkey("Node_Stripe", "Angle > Rotate CCW", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 90) % 360); });
	});
#endregion

function Node_Stripe(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Stripe";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Float("Amount", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] })
		.setMappable(11);
	
	newInput(2, nodeValue_Rotation("Angle", self, 0))
		.setMappable(12);
	
	newInput(3, nodeValue_Enum_Button("Type", self,  0, [ "Solid", "Smooth", "AA" ]));
	
	newInput(4, nodeValue_Vec2("Position", self, [ 0, 0 ] ))
		.setUnitRef(function(index) { return getDimension(index); });
		
	newInput(5, nodeValue_Float("Random", self, 0))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(13);
		
	newInput(6, nodeValue_Enum_Button("Coloring", self,  0, [ "Alternate", "Palette", "Random" ]));
	
	newInput(7, nodeValue_Gradient("Colors", self, new gradientObject(ca_white)))
		.setMappable(15);
	
	newInput(8, nodeValue_Color("Color 1", self, ca_white));
	
	newInput(9, nodeValue_Color("Color 2", self, ca_black));
	
	newInput(10, nodeValue_Float("Strip Ratio", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(14);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(11, nodeValueMap("Amount Map", self));
	
	newInput(12, nodeValueMap("Angle Map", self));
	
	newInput(13, nodeValueMap("Random Map", self));
	
	newInput(14, nodeValueMap("Ratio Map", self));
	
	newInput(15, nodeValueMap("Gradient Map", self));
	
	newInput(16, nodeValueGradientRange("Gradient Map Range", self, inputs[7]));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(17, nodeValue_Float("Progress", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
		
	newInput(18, nodeValue_Palette("Colors", self, [ c_black, c_white ] ));
		
	newInput(19, nodeValueSeed(self));
		
	newInput(20, nodeValue_Surface("Mask", self));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 19, 
		["Output",	true],	0, 20, 
		["Pattern",	false], 1, 11, 10, 14, 2, 12, 4, 5, 13, 17, 
		["Render",	false], 3, 6, 7, 15, 8, 9, 18, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var pos  = current_data[4];
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[ 4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[ 2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[16].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, current_data[0]));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim  = _data[0];
		var _bnd  = _data[3];
		var _pos  = _data[4];
		var _clr0 = _data[8];
		var _clr1 = _data[9];
		var _prg  = _data[17];
		var _pal  = _data[18];
		var _seed = _data[19];
		
		var _color = _data[6];
		
		inputs[ 8].setVisible(_color == 0);
		inputs[ 9].setVisible(_color == 0);
		inputs[18].setVisible(_color == 1);
		inputs[ 7].setVisible(_color == 2);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
			
		surface_set_shader(_outSurf, sh_stripe);
			shader_set_f("seed",		 _seed);
			shader_set_f("dimension",	 _dim[0], _dim[1]);
			shader_set_f("position",	 _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_i("blend",		 _bnd);
			shader_set_f("progress",	 _prg);
			
			shader_set_f_map("amount",		 _data[ 1], _data[11], inputs[ 1]);
			shader_set_f_map("angle",		 _data[ 2], _data[12], inputs[ 2]);
			shader_set_f_map("randomAmount", _data[ 5], _data[13], inputs[ 5]);
			shader_set_f_map("ratio",        _data[10], _data[14], inputs[10]);
			
			shader_set_i("coloring",	_color);
			
			shader_set_color("color0", _clr0);
			shader_set_color("color1", _clr1);
			shader_set_palette(_pal);
			
			shader_set_gradient(_data[7], _data[15], _data[16], inputs[7]);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}