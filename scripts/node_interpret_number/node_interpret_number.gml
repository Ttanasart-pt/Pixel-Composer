#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Interpret_Number", "Mode > Toggle", "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 2); });
	});
#endregion

function Node_Interpret_Number(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Interpret Number";
	dimension_index = -1;
	
	newInput(0, nodeValue_Float( "Number", [] )).setVisible(true, true).setArrayDepth(1);
	
	////- =Interpret
	
	newInput(1, nodeValue_Enum_Button( "Mode",      0, [ "Greyscale", "Gradient" ]));
	newInput(2, nodeValue_Range(       "Range",    [0,1] ));
	newInput(3, nodeValue_Gradient(    "Gradient", gra_white)).setMappable(4);
	
	// input 6
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0,
		["Interpret",	false], 1, 2, 3, 4, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, getDimension()));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		static BATCH_SIZE = 128;
		
		var _val = _data[0];
		var _mod = _data[1];
		var _ran = _data[2];
		
		inputs[3].setVisible(_mod == 1);
		
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