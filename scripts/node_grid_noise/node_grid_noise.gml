#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Grid_Noise", "Color Mode > Toggle", "C", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[7].setValue((_n.inputs[7].getValue() + 1) % 3); });
		addHotkey("Node_Grid_Noise", "Shift Axis > Toggle", "A", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[6].setValue((_n.inputs[6].getValue() + 1) % 2); });
	});
#endregion

function Node_Grid_Noise(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grid Noise";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(2, nodeValue_Vec2("Scale", self, [ 8, 8 ]));
	
	newInput(3, nodeValueSeed(self));
	
	newInput(4, nodeValue_Float("Shift", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-0.5, 0.5, 0.01] });
		
	newInput(5, nodeValue_Surface("Texture Sample", self));
	
	newInput(6, nodeValue_Enum_Button("Shift Axis", self,  0, ["x", "y"]));
	
	newInput(7, nodeValue_Enum_Button("Color Mode", self,  0, [ "Greyscale", "RGB", "HSV" ]));
	
	newInput(8, nodeValue_Slider_Range("Color R Range", self, [ 0, 1 ]));
	
	newInput(9, nodeValue_Slider_Range("Color G Range", self, [ 0, 1 ]));
	
	newInput(10, nodeValue_Slider_Range("Color B Range", self, [ 0, 1 ]));
	
	newInput(11, nodeValue_Surface("Mask", self));
	
	input_display_list = [
		["Output",	false], 0, 11, 
		["Noise",	false], 3, 1, 2, 6, 4, 
		["Render",	false], 5, 7, 8, 9, 10, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {

		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _sca = _data[2];
		var _sed = _data[3];
		var _shf = _data[4];
		var _sam = _data[5];
		var _shfAx = _data[6];
		
		var _col = _data[ 7];
		var _clr = _data[ 8];
		var _clg = _data[ 9];
		var _clb = _data[10];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_grid_noise);
		shader_set_f("dimension",  _dim);
		shader_set_2("position",   _pos);
		shader_set_2("scale",      _sca);
		shader_set_i("useSampler", is_surface(_sam));
		shader_set_f("shift",      _shf);
		shader_set_i("shiftAxis",  _shfAx);
		shader_set_f("seed",       _sed);
			
		shader_set_i("colored",    _col);
		shader_set_2("colorRanR",  _clr);
		shader_set_2("colorRanG",  _clg);
		shader_set_2("colorRanB",  _clb);
		
		if(is_surface(_sam))
			draw_surface_stretched_safe(_sam, 0, 0, _dim[0], _dim[1]);
		else
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}