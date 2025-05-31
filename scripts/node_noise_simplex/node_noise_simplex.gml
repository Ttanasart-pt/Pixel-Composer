#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Noise_Simplex", "Color Mode > Toggle", "C", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue((_n.inputs[4].getValue() + 1) % 3); });
	});
#endregion

function Node_Noise_Simplex(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Simplex Noise";
	
	////- =Output
	
	newInput( 0, nodeValue_Dimension());
	newInput(13, nodeValue_Surface( "Mask" ));
	
	////- =Noise
	
	newInput(14, nodeValueSeed());
	newInput( 3, nodeValue_ISlider(  "Iteration",   1, [1, 16, 0.1] )).setMappable(9);
	
	////- =Transform
	
	newInput( 1, nodeValue_Vec2(     "Position",   [0,0] ));
	newInput(10, nodeValue_Rotation( "Rotation",    0));
	newInput( 2, nodeValue_Vec2(     "Scale",      [4,4] )).setMappable(8);
	
	////- =Iteration
	
	newInput(11, nodeValue_Float(  "Scaling",    2));
	newInput(12, nodeValue_Slider( "Amplitude", .5));
	
	////- =Render
	
	newInput( 4, nodeValue_Enum_Button(  "Color Mode",     0, [ "Greyscale", "RGB", "HSV" ]));
	newInput( 5, nodeValue_Slider_Range( "Color R Range", [0,1] ));
	newInput( 6, nodeValue_Slider_Range( "Color G Range", [0,1] ));
	newInput( 7, nodeValue_Slider_Range( "Color B Range", [0,1] ));
	
	// input 15
	
	input_display_list = [
		["Output",      true], 0, 13, 
		["Noise",      false], 14, 3, 9, 
		["Transform",  false], 1, 10, 2, 8, 
		["Iteration",   true], 11, 12, 
		["Render",     false], 4, 5, 6, 7, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
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
		var _sed = _data[14];
		
		var _adv_scale  = _data[11];
		var _adv_amplit = _data[12];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_simplex);
			shader_set_f("seed",      _sed);
			shader_set_f("dimension", _dim);
			shader_set_2("position",  _pos);
			shader_set_f("rotation",  degtorad(_ang));
			shader_set_f_map("scale",     _data[2], _data[8], inputs[2]);
			shader_set_f_map("iteration", _data[3], _data[9], inputs[3]);
			
			shader_set_f("itrAmplitude", _adv_amplit);
			shader_set_f("itrScaling",   _adv_scale);
		
			shader_set_i("colored",   _col);
			shader_set_2("colorRanR", _clr);
			shader_set_2("colorRanG", _clg);
			shader_set_2("colorRanB", _clb);
			
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