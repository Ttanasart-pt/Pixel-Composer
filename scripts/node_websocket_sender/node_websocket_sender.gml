function Node_Websocket_Sender(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Websocket Sender";
	
	w = 128;
	h = 128;
	min_h = h;
	
	inputs[| 0] = nodeValue("Port", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 22800);
	
	inputs[| 1] = nodeValue("Data type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Struct", "Surface", "File", "Buffer" ]);
	
	inputs[| 2] = nodeValue("Struct", self, JUNCTION_CONNECT.input, VALUE_TYPE.struct, {});
	
	inputs[| 3] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 4] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load)
		.nonValidate();
	
	inputs[| 5] = nodeValue("Target", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "127.0.0.1");
	
	inputs[| 6] = nodeValue("Buffer", self, JUNCTION_CONNECT.input, VALUE_TYPE.buffer, noone);
	
	input_display_list = [ 5, 0, 1, 2, 3, 4, 6 ];
	
	port = 0;
	url  = "";
	connected = false;
	socket = noone;
	
	function connectTo(newPort, newUrl) {
		if(ds_map_exists(PORT_MAP, port))
			array_remove(PORT_MAP[? port], self);
		
		port = newPort;
		url  = newUrl;
		
		if(!ds_map_exists(PORT_MAP, port))
			PORT_MAP[? port] = [];
		array_push(PORT_MAP[? port], self);
		
		if(ds_map_exists(NETWORK_CLIENTS, newPort))
			return;
		
		if(socket >= 0) network_destroy(socket);
		socket = network_create_socket(network_socket_ws);
		if(socket < 0) return;
		
		network_connect_raw_async(socket, newUrl, newPort);
		connected = false;
		NETWORK_CLIENTS[? newPort] = socket;
	}
	
	insp1UpdateTooltip  = __txt("Reconnect");
	insp1UpdateIcon     = [ THEME.refresh, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() {
		var _port = inputs[| 0].getValue();
		var _url  = inputs[| 5].getValue();
		connectTo(_port, _url);
	}
	
	static asyncPackets = function(_async_load) {
		if(!active) return;
		
		var type = async_load[? "type"];
		
		switch(type) {
			case network_type_non_blocking_connect :
				noti_status($"Websocket client: Connected at port {port} on node {display_name}");
				connected = true;
				break;
		}
	}
	
	static step = function() {
		var _type = inputs[| 1].getValue();
		
		inputs[| 2].setVisible(_type == 0, _type == 0);
		inputs[| 3].setVisible(_type == 1, _type == 1);
		inputs[| 4].setVisible(_type == 2, _type == 2);
		inputs[| 6].setVisible(_type == 3, _type == 3);
	}
	
	static update = function(frame = ANIMATOR.current_frame) { 
		var _port   = inputs[| 0].getValue();
		var _target = inputs[| 5].getValue();
		
		if(port != _port || url != _target)
			connectTo(_port, _target);
		
		var network = ds_map_try_get(NETWORK_CLIENTS, _port, noone);
		if(network < 0) return;
		
		var _type = inputs[| 1].getValue();
		var _buff, res;
		
		switch(_type) {
			case 0 :
				var _stru = inputs[| 2].getValue();
				var _str  = json_stringify(_stru);
				_buff = buffer_from_string(_str);
				res   = network_send_raw(network, _buff, buffer_get_size(_buff), network_send_text);
				break;
			case 1 :
				var _surf = inputs[| 3].getValue();
				if(!is_surface(_surf)) return;
				_buff = buffer_from_surface(_surf);
				res   = network_send_raw(network, _buff, buffer_get_size(_buff), network_send_text);
				break;
			case 2 :
				var _path = inputs[| 4].getValue();
				if(!file_exists(_path)) return;
				_buff = buffer_from_file(_path);
				res   = network_send_raw(network, _buff, buffer_get_size(_buff), network_send_text);
				break;
			case 3 :
				_buff = inputs[| 6].getValue();
				if(!buffer_exists(_buff)) return;
				res   = network_send_raw(network, _buff, buffer_get_size(_buff), network_send_text);
				break;
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox    = drawGetBbox(xx, yy, _s);
		var network = ds_map_try_get(NETWORK_CLIENTS, port, noone);
		
		var cc = CDEF.red, aa = 1;
		if(network >= 0) cc = CDEF.lime;
		
		var _y0 = bbox.y0 + ui(16);
		var _y1 = bbox.y1 - ui(16);
		var _ts = _s * 0.75;
		
		draw_set_text(f_code, fa_center, fa_top, COLORS._main_text);
		draw_set_alpha(0.75);
		draw_text_add(bbox.xc, bbox.y0, $"Port {port}", _ts);
		draw_set_alpha(1);
		
		draw_sprite_fit(THEME.node_websocket_send, 0, bbox.xc, (_y0 + _y1) / 2, bbox.w, _y1 - _y0, cc, aa);
	}
}