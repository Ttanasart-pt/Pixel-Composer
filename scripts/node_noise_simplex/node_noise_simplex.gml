#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Noise_Simplex", "Color Mode > Toggle", "C", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue((_n.inputs[4].getValue() + 1) % 3); });
	});
#endregion

function Node_Noise_Simplex(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Simplex Noise";
	
	newInput(0, nodeValue_Dimension());
	
	newInput(1, nodeValue_Vec3("Position", [ 0, 0, 0 ] ));
	
	newInput(2, nodeValue_Vec2("Scale", [ 1, 1 ] ))
		.setMappable(8);
	
	newInput(3, nodeValue_Int("Iteration", 1 ))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] })
		.setMappable(9);
	
	newInput(4, nodeValue_Enum_Button("Color Mode", 0, [ "Greyscale", "RGB", "HSV" ]));
	
	newInput(5, nodeValue_Slider_Range("Color R Range", [ 0, 1 ]));
	
	newInput(6, nodeValue_Slider_Range("Color G Range", [ 0, 1 ]));
	
	newInput(7, nodeValue_Slider_Range("Color B Range", [ 0, 1 ]));
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(8, nodeValueMap("Scale map", self));
	
	newInput(9, nodeValueMap("Iteration map", self));
	
	//////////////////////////////////////////////////////////////////////////////////
		
	newInput(10, nodeValue_Rotation("Rotation", 0));
		
	newInput(11, nodeValue_Float("Scaling", 2.));
	
	newInput(12, nodeValue_Float("Amplitude", .5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(13, nodeValue_Surface("Mask"));
	
	input_display_list = [
		["Output",   false], 0, 13, 
		["Noise",    false], 1, 10, 2, 8, 3, 9, 
		["Advances",  true], 11, 12, 
		["Render",   false], 4, 5, 6, 7, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static step = function() {
		var _col = getInputData(4);
		
		inputs[5].setVisible(_col != 0);
		inputs[6].setVisible(_col != 0);
		inputs[7].setVisible(_col != 0);
		
		inputs[5].name = _col == 1? "Color R Range" : "Color H Range";
		inputs[6].name = _col == 1? "Color G Range" : "Color S Range";
		inputs[7].name = _col == 1? "Color B Range" : "Color V Range";
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		
		var _col = _data[4];
		var _clr = _data[5];
		var _clg = _data[6];
		var _clb = _data[7];
		var _ang = _data[10];
		
		var _adv_scale  = _data[11];
		var _adv_amplit = _data[12];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_simplex);
			shader_set_f("dimension", _dim);
			shader_set_3("position",  _pos);
			shader_set_f("rotation",  degtorad(_ang));
			shader_set_f_map("scale",     _data[2], _data[8], inputs[2]);
			shader_set_f_map("iteration", _data[3], _data[9], inputs[3]);
			
			shader_set_i("colored",   _col);
			shader_set_2("colorRanR", _clr);
			shader_set_2("colorRanG", _clg);
			shader_set_2("colorRanB", _clb);
			
			shader_set_f("itrAmplitude", _adv_amplit);
			shader_set_f("itrScaling",   _adv_scale);
		
			draw_empty();
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
}