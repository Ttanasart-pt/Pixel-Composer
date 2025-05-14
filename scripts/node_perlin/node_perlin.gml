#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Perlin", "Color Mode > Toggle", "C", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[6].setValue((_n.inputs[6].getValue() + 1) % 3); });
	});
#endregion

function Node_Perlin(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Perlin Noise";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(2, nodeValue_Vec2("Scale", self, [ 5, 5 ]))
		.setMappable(10);
	
	newInput(3, nodeValue_Int("Iteration", self, 4));
	
	newInput(4, nodeValue_Bool("Tile", self, true));
		
	newInput(5, nodeValueSeed(self));
		
	newInput(6, nodeValue_Enum_Button("Color Mode", self,  0, [ "Greyscale", "RGB", "HSV" ]));
	
	newInput(7, nodeValue_Slider_Range("Color R Range", self, [ 0, 1 ]));
	
	newInput(8, nodeValue_Slider_Range("Color G Range", self, [ 0, 1 ]));
	
	newInput(9, nodeValue_Slider_Range("Color B Range", self, [ 0, 1 ]));
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(10, nodeValueMap("Scale map", self));
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(11, nodeValue_Rotation("Rotation", self, 0));
		
	newInput(12, nodeValue_Surface("Mask", self));
	
	newInput(13, nodeValue_Rotation("Phase", self, 0));
	
	input_display_list = [
		["Output", 	   true], 0, 12, 
		["Noise",	  false], 5, 13, 3, 4, 
		["Transform", false], 1, 11, 2, 10, 
		["Render",	  false], 6, 7, 8, 9, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _ite = _data[3];
		var _til = _data[4];
		var _sed = _data[5];
		
		var _col = _data[ 6];
		var _clr = _data[ 7];
		var _clg = _data[ 8];
		var _clb = _data[ 9];
		var _rot = _data[11];
		var _phs = _data[13];
		
		inputs[7].setVisible(_col != 0);
		inputs[8].setVisible(_col != 0);
		inputs[9].setVisible(_col != 0);
		
		inputs[7].name = _col == 1? "Color R Range" : "Color H Range";
		inputs[8].name = _col == 1? "Color G Range" : "Color S Range";
		inputs[9].name = _col == 1? "Color B Range" : "Color V Range";
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_perlin_tiled);
			shader_set_2("dimension",  _dim);
			shader_set_2("position",   _pos);
			shader_set_f("rotation",   degtorad(_rot));
			shader_set_f_map("scale",  _data[2], _data[10], inputs[2]);
			shader_set_f("seed",       _sed);
			shader_set_f("phase",      _phs / 360);
			shader_set_i("tile",       _til);
			shader_set_i("iteration",  _ite);
		
			shader_set_i("colored",   _col);
			shader_set_2("colorRanR", _clr);
			shader_set_2("colorRanG", _clg);
			shader_set_2("colorRanB", _clb);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}