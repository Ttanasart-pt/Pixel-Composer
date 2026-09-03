#region create
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Delay", "Overflow > Toggle",  "O", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 3); });
	});
#endregion

function Node_Delay(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Delay";
	is_simulation   = true;
	update_on_frame = true;
	
	newInput( 0, nodeValue_Surface( "Surface"));
	
	////- =Delay
	newInput( 1, nodeValue_Int(     "Frames",   1 )).setPieMenu();
	newInput( 2, nodeValue_EScroll( "Overflow", 0, [ "Hold", "Loop", "Clear" ])).setPieMenu();
	
	////- =Array
	newInput( 3, nodeValue_Bool(    "Use Array",   false ));
	newInput( 4, nodeValue_Int(     "Array Index", 0     ));
	// 5
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Delay", false    ],  1,  2, 
		[ "Array", false, 3 ],  4, 
	];
	
	////- Node
	
	surf_indexes = [];
	curr_frame   = 0;
	
	// static processData_prebatch  = function() {
	// 	surf_indexes = array_verify(surf_indexes, process_amount);
	// 	for( var i = 0; i < process_amount; i++ ) 
	// 		surf_indexes[i] = array_verify(surf_indexes[i], TOTAL_FRAMES);
	// }
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		#region data
			var _surf = _data[ 0];
			
			var _frme = _data[ 1];
			var _ovrf = _data[ 2];
			
			var _arr  = _data[ 3];
			var _arri = _data[ 4];
		#endregion
		
		var _time = CURRENT_FRAME;
		var _totl = TOTAL_FRAMES;
		
		var _frtm = _time - _frme;
		switch(_ovrf) {
			case 0 : _frtm = clamp(_frtm, 0, _totl - 1); break;
			case 1 : _frtm = (_frtm + _totl) % _totl;    break;
		}
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		var _ind = _arr? _arri : _array_index;
		surf_indexes = array_verify_min(surf_indexes, _ind+1);
		surf_indexes[_ind] = array_verify(surf_indexes[_ind], TOTAL_FRAMES);
		
		var _surfA = surf_indexes[_ind];
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
	
	////- Draw
	
	static drawAnimationTimeline = function(_shf, _w, _h, _s) {
		draw_set_color(COLORS._main_value_positive);
		draw_set_alpha(1);
		
		var _x = _shf + (curr_frame + 1) * _s;
		draw_line_width(_x, 0, _x, _h, 1);
		draw_set_alpha(1);
	}
	
	////- Action
	
	static cleanUp = function() {
		surface_array_free(surf_indexes);
	}
	
}