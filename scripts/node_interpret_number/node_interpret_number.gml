function Node_Interpret_Number(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Interpret Number";
	dimension_index = -1;
	
	inputs[| 0] = nodeValue("Number", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [] )
		.setVisible(true, true)
		.setArrayDepth(1);
	
	inputs[| 1] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Greyscale", "Gradient" ]);
	
	inputs[| 2] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 3] = nodeValue("Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) );
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0,
		["Interpret",	false], 1, 2, 3, 
	];
	
	attribute_surface_depth();
	
	static step = function() {
		var _mode = getInputData(1);
		
		inputs[| 3].setVisible(_mode == 1);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		static BATCH_SIZE = 128;
		
		var _val = _data[0];
		var _mod = _data[1];
		var _ran = _data[2];
		var _grd = _data[3];
		
		if(is_array(_val) && array_empty(_val)) return _outSurf;
		if(!is_array(_val)) _val = [ _val ];
		var _num = array_spread(_val);
		var _amo = array_length(_num);
		
		_outSurf = surface_verify(_outSurf, _amo, 1, attrDepth());
		if(_amo == 0) return _outSurf;
		
		surface_set_shader(_outSurf, sh_interpret_number);
			shader_set_i("mode", _mod);
			shader_set_f("range", _ran);
			_grd.shader_submit();
			
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