function Node_Spout_Send(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name	= "Spout Send";
	
	newInput( 0, nodeValue_Text(    "Sender name", "PixelComposer" ));
	newInput( 1, nodeValue_Surface( "Surface" ));
	// 2
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone)).setVisible(false);
	
	input_display_list = [ 0, 
		1, 
	];
	
	inputs[0].getEditWidget().autocomplete_server = spout_autocomplete_server;
	
	////- Node
	
	spoutIndex = spout_sender_create();
	if(spoutIndex < 0) noti_warning("Spout initialize error", noone, self);
	
	surf_buff = buffer_create(1, buffer_grow, 1);
	
	static update = function() {
		if(spoutIndex < 0) return;
		
		var _name = inputs[0].getValue();
		var _surf = inputs[1].getValue();
		
		if(!is_surface(_surf)) return;
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		buffer_resize(surf_buff, _sw * _sh * 4);
		buffer_get_surface(surf_buff, _surf, 0);
		
		spout_sender_set_name(spoutIndex, _name);
		spout_sender_send(spoutIndex, buffer_get_address(surf_buff), _sw, _sh);
		
		outputs[0].setValue(_surf);
	}
}

function spout_autocomplete_server(prompt, params = []) {
	var res = [];
	
	var pr_list = ds_priority_create();
	
	//////////////////////////////////
	ds_priority_clear(pr_list);
	
	var sender_count = spout_sender_count();
	for( var i = 0; i < sender_count; i++ ) {
		var _name = spout_sender_get_name(i);
		
		var match = string_partial_match(string_lower(_name), string_lower(prompt));
		if(match == -9999) continue;
		
		ds_priority_add(pr_list, [[THEME.ac_constant, 2], _name, "spout", _name], match);
	}
	
	repeat(ds_priority_size(pr_list))
		array_push(res, ds_priority_delete_max(pr_list));
	
	ds_priority_destroy(pr_list);
	
	return res;
}