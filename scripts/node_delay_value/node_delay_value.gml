#region create
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Delay_Value", "Overflow > Toggle",  "O", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 3); });
	});
#endregion

function Node_Delay_Value(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Delay Value";
	always_pad = true;
	is_simulation = true;
	setDimension(96, 48);
	
	newInput(0, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, noone))
	    .setVisible(true, true);
	
	newInput(1, nodeValue_Int("Frames", 1));
	
	newInput(2, nodeValue_Enum_Scroll("Overflow", 0, [ "Hold", "Loop", "Value" ]));
	
	newInput(3, nodeValue("Default", self, CONNECT_TYPE.input, VALUE_TYPE.any, noone));
	
	newOutput(0, nodeValue_Output("Value", VALUE_TYPE.any, noone));
	
	input_display_list = [ 0, 
		["Delay",  false], 1, 2, 3, 
	];
	
	data_indexes = [];
	curr_frame   = 0;
	
	static processData_prebatch  = function() {
		data_indexes = array_verify(data_indexes, process_amount);
		for( var i = 0; i < process_amount; i++ ) 
			data_indexes[i] = array_verify(data_indexes[i], TOTAL_FRAMES);
			
		var _ovr = getInputSingle(2);
		inputs[3].setVisible(_ovr == 2, _ovr == 2);
		
		var _frm = inputs[0].value_from;
		var _typ = _frm == noone? VALUE_TYPE.any : _frm.type;
		
		inputs[0].setType(_typ);
		outputs[0].setType(_typ);
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		var _val  = _data[0];
		var _frme = _data[1];
		var _ovrf = _data[2];
		var _def  = _data[3];
		
		var _time = CURRENT_FRAME;
		var _totl = TOTAL_FRAMES;
		
		var _frtm = _time - _frme;
		switch(_ovrf) {
			case 0 : _frtm = clamp(_frtm, 0, _totl - 1); break;
			case 1 : _frtm = (_frtm + _totl) % _totl;    break;
		}
		curr_frame = _frtm;
		
		var _surfA    = data_indexes[_array_index];
		_surfA[_time] = variable_clone(_val);
		
		return array_safe_get(_surfA, _frtm, _def);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = getInputSingle(0, preview_index, true);
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
	
	static drawAnimationTimeline = function(_shf, _w, _h, _s) {
		draw_set_color(COLORS._main_value_positive);
		draw_set_alpha(1);
		
		var _x = _shf + (curr_frame + 1) * _s;
		draw_line_width(_x, 0, _x, _h, 1);
		draw_set_alpha(1);
	}
	
}