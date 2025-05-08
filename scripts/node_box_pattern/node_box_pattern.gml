#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Box_Pattern", "Render Type > Toggle", "R", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[ 8].setValue((_n.inputs[ 8].getValue() + 1) % 3); });
		addHotkey("Node_Box_Pattern", "Pattern > Toggle",     "P", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[11].setValue((_n.inputs[11].getValue() + 1) % 2); });
	});
#endregion

function Node_Box_Pattern(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Box Pattern";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Float("Scale", self, 2))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] })
		.setMappable(6);
	
	newInput(2, nodeValue_Rotation("Angle", self, 0))
		.setMappable(7);
	
	newInput(3, nodeValue_Vec2("Position", self, [0, 0] ))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(4, nodeValue_Color("Color 1", self, ca_white));
	
	newInput(5, nodeValue_Color("Color 2", self, ca_black));
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(6, nodeValueMap("Amount Map", self));
	
	newInput(7, nodeValueMap("Angle Map", self));
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(8, nodeValue_Enum_Button("Render Type", self,  0, [ "Solid", "Smooth", "AA" ]));
	
	newInput(9, nodeValue_Float("Width", self, 0.25))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(10);
	
	newInput(10, nodeValueMap("Width Map", self));
	
	newInput(11, nodeValue_Enum_Button("Pattern", self,  0, [ "Cross", "Xor" ]));
	
	newInput(12, nodeValue_Int("Iteration", self, 4))
	
	newInput(13, nodeValue_Surface("Mask", self));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Output",	true],	0, 13, 
		["Pattern",	false], 11, 1, 6, 2, 7, 3, 9, 10, 12, 
		["Render",	false], 8, 4, 5,
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos  = getInputData(3);
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static step = function() {
		var _pat = getSingleValue(11);
		inputs[ 9].setVisible(_pat == 0);
		inputs[12].setVisible(_pat == 1);
		
		inputs[1].mappableStep();
		inputs[2].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[3];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
			
		surface_set_shader(_outSurf, sh_box_pattern);
			shader_set_f("dimension",   surface_get_width_safe(_outSurf), surface_get_height_safe(_outSurf));
			shader_set_f("position",   _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f_map("amount", _data[1], _data[ 6], inputs[1]);
			shader_set_f_map("angle",  _data[2], _data[ 7], inputs[2]);
			shader_set_f_map("width",  _data[9], _data[10], inputs[9]);
			shader_set_color("col1",   _data[4]);
			shader_set_color("col2",   _data[5]);
			shader_set_i("blend",	   _data[8]);
			shader_set_i("pattern",	   _data[11]);
			shader_set_i("iteration",  _data[12]);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}