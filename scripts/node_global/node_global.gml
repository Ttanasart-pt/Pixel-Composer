function Node_Global(_x, _y) constructor {
	name	= "Global variable";
	x = _x;
	y = _y;
	
	use_cache = false;
	inputs  = ds_list_create();
	outputs = ds_list_create();
	input_display_list = -1;
	
	inputs[| 0] = nodeValue(0, "Default Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 );
	inputs[| 0].setDisplay(VALUE_DISPLAY.vector);
	
	static serialize = function() {
		var _map = ds_map_create();
		var _inputs = ds_list_create();
		for(var i = 0; i < ds_list_size(inputs); i++) {
			ds_list_add(_inputs, inputs[| i].serialize());	
			ds_list_mark_as_map(_inputs, i);
		}
		ds_map_add_list(_map, "inputs", _inputs);
		return _map;
	}
	
	static deserialize = function(_map) {
		var _inputs = _map[? "inputs"];
		
		if(!ds_list_empty(_inputs) && !ds_list_empty(inputs)) {
			var _siz = min(ds_list_size(_inputs), ds_list_size(inputs));
			for(var i = 0; i < _siz; i++) {
				inputs[| i].deserialize(_inputs[| i]);
			}
		}
	}
}