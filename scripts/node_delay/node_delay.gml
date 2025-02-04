#region create
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Delay", "Overflow > Toggle",  "O", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 3); });
	});
#endregion

function Node_Delay(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Delay";
	
	is_simulation = true;
	
	newInput(0, nodeValue_Surface("Surface", self));
	
	newInput(1, nodeValue_Int("Frames", self, 1));
	
	newInput(2, nodeValue_Enum_Scroll("Overflow", self, 0, [ "Hold", "Loop", "Clear" ]));
	
	newOutput(0, nodeValue_Output("Surface", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		["Delay",  false], 1, 2, 
	];
	
	surf_indexes = [];
	curr_frame   = 0;
	
	static processData_prebatch  = function() {
		surf_indexes = array_verify(surf_indexes, process_amount);
		for( var i = 0; i < process_amount; i++ ) 
			surf_indexes[i] = array_verify(surf_indexes[i], TOTAL_FRAMES);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _surf = _data[0];
		var _frme = _data[1];
		var _ovrf = _data[2];
		
		var _time = CURRENT_FRAME;
		var _totl = TOTAL_FRAMES;
		
		var _frtm = _time - _frme;
		switch(_ovrf) {
			case 0 : _frtm = clamp(_frtm, 0, _totl - 1); break;
			case 1 : _frtm = (_frtm + _totl) % _totl;    break;
		}
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		var _surfA = surf_indexes[_array_index];
		_surfA[_time] = surface_verify(_surfA[_time], _sw, _sh);
		
		surface_set_shader(_surfA[_time], sh_sample, true, BLEND.over);
			draw_surface_safe(_surf);
		surface_reset_target();
		
		_output = surface_verify(_output, _sw, _sh);
		surface_set_shader(_output, sh_sample, true, BLEND.over);
		if(0 <= _frtm && _frtm < _totl)
			draw_surface_safe(_surfA[_frtm]);
		surface_reset_target();
		
		curr_frame = _frtm;
		
		return _output;
	}
	
	
	static drawAnimationTimeline = function(_shf, _w, _h, _s) {
		draw_set_color(COLORS._main_value_positive);
		draw_set_alpha(1);
		
		var _x = _shf + (curr_frame + 1) * _s;
		draw_line_width(_x, 0, _x, _h, 1);
		draw_set_alpha(1);
	}
	
}