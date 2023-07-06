function Node_Websocket_Receiver(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Websocket Receiver";
	
	w = 128;
	h = 128;
	min_h = h;
	
	inputs[| 0] = nodeValue("Port", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 22400);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	outputs[| 0] = nodeValue("Data", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, {});
	
	outputs[| 1] = nodeValue("Receive data", self, JUNCTION_CONNECT.output, VALUE_TYPE.trigger, 0);
	
	input_display_list = [ 1, 0 ];
	
	connected_device = 0;
	port   = 0;
	socket = noone;
	
	function setPort(newPort) {
		if(ds_map_exists(PORT_MAP, port))
			array_remove(PORT_MAP[? port], self);
		
		port = newPort;
		if(!ds_map_exists(PORT_MAP, port))
			PORT_MAP[? port] = [];
		array_push(PORT_MAP[? port], self);
		
		if(ds_map_exists(NETWORK_SERVERS, newPort))
			return;
		
		if(socket >= 0) network_destroy(socket);
		socket = network_create_server_raw(network_socket_ws, newPort, 16)
		if(socket < 0) return;
		
		NETWORK_SERVERS[? newPort] = socket;
	}
	
	insp1UpdateTooltip  = __txt("Refresh Server");
	insp1UpdateIcon     = [ THEME.refresh, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() {
		var _port = inputs[| 0].getValue();
		
		setPort(_port);
	}
	
	network_trigger = 0;
	static asyncPackets = function(_async_load) {
		if(!active) return;
		
		var _active = inputs[| 1].getValue();
		if(!_active) return;
		
		var type = async_load[? "type"];
		
		switch(type) {
			case network_type_connect :
				noti_status($"Websocket server: Client connected at port {port} on node {display_name}");
				connected_device++;
				break;
			case network_type_disconnect :
				noti_status($"Websocket server: Client disconnected at port {port} on node {display_name}");
				connected_device--;
				break;
			case network_type_data :
				var buffer = async_load[? "buffer"];
				var socket = async_load[? "id"];
				var data = buffer_get_string(buffer);
				
				var _data = json_try_parse(data, noone);
				if(_data == noone)	_data = { rawData: new Buffer(buffer) }
				else				buffer_delete(buffer);
					
				outputs[| 0].setValue(_data);
				network_trigger = true;
				break;
		}
	}
	
	static step = function() {
		if(network_trigger == 1) {
			outputs[| 1].setValue(1);
			network_trigger = -1;
		} else if(network_trigger == -1) {
			outputs[| 1].setValue(0);
			network_trigger = 0;
		}
	}
	
	static update = function(frame = PROJECT.animator.current_frame) { 
		if(CLONING) return;
		var _port = inputs[| 0].getValue();
		
		if(port != _port)
			setPort(_port);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var _active = inputs[| 1].getValue();
		var bbox    = drawGetBbox(xx, yy, _s);
		var network = ds_map_try_get(NETWORK_SERVERS, port, noone);
		
		var cc = CDEF.red, aa = 1;
		if(network >= 0) cc = CDEF.lime;
		if(!_active) aa = 0.5;
		
		var _y0 = bbox.y0 + ui(16);
		var _y1 = bbox.y1 - ui(16);
		var _ts = _s * 0.75;
		
		draw_set_text(f_code, fa_center, fa_top, COLORS._main_text);
		draw_set_alpha(0.75);
		draw_text_add(bbox.xc, bbox.y0, $"Port {port}", _ts);
		draw_set_valign(fa_bottom)
		draw_text_add(bbox.xc, bbox.y1, $"{connected_device} Connected", _ts);
		draw_set_alpha(1);
		
		draw_sprite_fit(THEME.node_websocket_receive, 0, bbox.xc, (_y0 + _y1) / 2, bbox.w, _y1 - _y0, cc, aa);
	}
}