function Node_Spout_Receive(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name	= "Spout Receive";
	
	newInput( 0, nodeValue_Text( "Receiver name", "PixelComposer" ));
	
	////- =Update
	newInput( 1, nodeValue_Bool(  "Animated",     true ));
	// 2
	
	newOutput( 0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Update", false ],  1, 
	];
	
	inputs[0].getEditWidget().autocomplete_server = spout_autocomplete_server;
	
	////- Node
	
	// spout_set_log(true);
	
	spoutIndex = spout_receiver_create();
	if(spoutIndex < 0) noti_warning("Spout initialize error", noone, self);
	
	// var os_info = os_get_info();
	// var dxCtx   = os_info[? "video_d3d11_device"];
	// spout_receiver_set_context(spoutIndex, dxCtx);
	
	connected = false;
	surf_buff = buffer_create(1, buffer_grow, 1);
	
	static step = function() {
		
	}
	
	static update = function() {
		if(spoutIndex < 0) return;
		
		var _name       = inputs[0].getValue();
		update_on_frame = inputs[1].getValue();
		
		spout_receiver_set_name(spoutIndex, _name);
		var _sw = spout_receiver_width(spoutIndex);
		var _sh = spout_receiver_height(spoutIndex);
		
		var _surf = outputs[0].getValue();
		    _surf = surface_verify(_surf, _sw, _sh);
		outputs[0].setValue(_surf);
		
		buffer_resize(surf_buff, _sw * _sh * 4);
		var res = spout_receiver_receive(spoutIndex, buffer_get_address(surf_buff));
		
		var _surf = outputs[0].getValue();
		buffer_set_surface(surf_buff, _surf, 0);
		
		connected = spout_receiver_connected(spoutIndex);
		newFrame  = spout_receiver_new_frame(spoutIndex);
	}
}