function Node_Interpret_Number(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Interpret Number";
	dimension_index = -1;
	
	inputs[0] = nodeValue_Float("Number", self, [] )
		.setVisible(true, true)
		.setArrayDepth(1);
	
	newInput(1, nodeValue_Enum_Button("Mode", self,  0, [ "Greyscale", "Gradient" ]));
	
	newInput(2, nodeValue_Range("Range", self, [ 0, 1 ] ));
	
	inputs[3] = nodeValue_Gradient("Gradient", self, new gradientObject(cola(c_white)))
		.setMappable(4);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(4, nodeValueMap("Gradient map", self));
	
	newInput(5, nodeValueGradientRange("Gradient map range", self, inputs[3]));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0,
		["Interpret",	false], 1, 2, 3, 4, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[5].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, getDimension()); active &= !hv; _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		var _mode = getInputData(1);
		
		inputs[3].setVisible(_mode == 1);
		inputs[3].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		static BATCH_SIZE = 128;
		
		var _val = _data[0];
		var _mod = _data[1];
		var _ran = _data[2];
		
		if(is_array(_val) && array_empty(_val)) return _outSurf;
		if(!is_array(_val)) _val = [ _val ];
		var _num = array_spread(_val);
		var _amo = array_length(_num);
		
		_outSurf = surface_verify(_outSurf, _amo, 1, attrDepth());
		if(_amo == 0) return _outSurf;
		
		surface_set_shader(_outSurf, sh_interpret_number);
			shader_set_i("mode", _mod);
			shader_set_f("range", _ran);
			
			shader_set_gradient(_data[3], _data[4], _data[5], inputs[3]);
			
			for(var i = 0; i < _amo; i += BATCH_SIZE) {
				var _arr = [];
				array_copy(_arr, 0, _num, i, BATCH_SIZE);
				shader_set_f("number", _arr);
				
				draw_sprite_stretched(s_fx_pixel, 0, i, 0, BATCH_SIZE, 1);
			}
		surface_reset_shader();
		
		return _outSurf;
	}
}