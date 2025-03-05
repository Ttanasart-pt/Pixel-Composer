#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Noise_Aniso", "Render Mode > Toggle",  "M", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 2); });
		addHotkey("Node_Noise_Aniso", "Rotation > Rotate CCW", "R", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[4].setValue((_n.inputs[4].getValue() + 90) % 360); });
	});
#endregion

function Node_Noise_Aniso(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Anisotropic Noise";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Float("X Amount", self, 2))
		.setMappable(6);
	
	newInput(2, nodeValueSeed(self));
	
	newInput(3, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(4, nodeValue_Rotation("Rotation", self, 0))
		.setMappable(8);
	
	newInput(5, nodeValue_Float("Y Amount", self, 16))
		.setMappable(7);
		
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(6, nodeValueMap("X Amount map", self));
	
	newInput(7, nodeValueMap("Y Amount map", self));
	
	newInput(8, nodeValueMap("Rotation map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(9, nodeValue_Enum_Scroll("Render Mode", self,  0, [ "Blend", "Waterfall" ] ))
		
	newInput(10, nodeValueSeed(self));
	
	newInput(11, nodeValue_Surface("Mask", self));
	
	input_display_list = [
		["Output",	false], 0, 11, 
		["Noise",	false], 2, 1, 6, 5, 7, 3, 4, 8, 
		["Render",	false], 9, 10, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[3].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		inputs[1].mappableStep();
		inputs[4].mappableStep();
		inputs[5].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[3];
		var _mod = _data[9];
		
		inputs[10].setVisible(_mod == 0);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_ani_noise);
			shader_set_2("dimension",   _dim);
			shader_set_f("position",	_pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f("seed",		_data[2]);
			shader_set_f("colrSeed",	_data[10]);
			
			shader_set_f_map("noiseX",  _data[1], _data[6], inputs[1]);
			shader_set_f_map("noiseY",  _data[5], _data[7], inputs[5]);
			shader_set_f_map("angle",	_data[4], _data[8], inputs[4]);
			
			shader_set_i("mode",		_mod);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}