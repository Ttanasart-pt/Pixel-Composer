function Node_Websocket_Receiver(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Websocket Receiver";
		
	newInput(0, nodeValue_Int("Port", 22400));
	
	newActiveInput(1);
	
	newInput(2, nodeValue_Enum_Button("Mode",  1, [ "Client", "Server" ]));
	
	newInput(3, nodeValue_Text("Url"));
	
	newOutput(0, nodeValue_Output("Data", VALUE_TYPE.struct, {}));
	
	newOutput(1, nodeValue_Output("Receive data", VALUE_TYPE.trigger, false));
	
	input_display_list = [ 1, 2,
		["Connection", false], 0, 3,
	];
	
	connected_device = 0;
	network_trigger  = 0;
	port   = 0;
	mode   = 0;
	url    = "";
	socket = noone;
	client = noone;
	
	setTrigger(1, __txt("Refresh Server"), [ THEME.refresh_icon, 1, COLORS._main_value_positive ], function() /*=>*/ {return setPort()});
	
	function setPort() {
		
		var _port = getInputData(0);
		var _mode = getInputData(2);
		var _url  = getInputData(3);
		if(_port == port && _mode == mode && _url == url) return;
		
		port = _port;
		mode = _mode;
		url	 = _url;
		
		if(ds_map_exists(PORT_MAP, port))
			array_remove(PORT_MAP[? port], self);
		
		if(!ds_map_exists(PORT_MAP, port))
			PORT_MAP[? port] = [];
		array_push(PORT_MAP[? port], self);
		
		if(socket != noone) 
			network_destroy(socket);
			
		if(mode == 0) {
			client = network_create_socket(network_socket_ws);
			network_connect_raw(client, url, port);
			
		} else if(mode == 1) {
			socket = network_create_server_raw(network_socket_ws, port, 16);
			if(socket) NETWORK_SERVERS[? port] = socket;
		}
	}
	
	static asyncPackets = function(_async_load) {
		if(project.online) return false;
		
		if(!active) return;
		
		var _active = getInputData(1);
		if(!_active) return;
		
		var type = async_load[? "type"];
		
		switch(type) {
			case network_type_connect :
				var _txt = $"Websocket server: Client connected at port {port} on node {display_name}";
				noti_status(_txt, noone, self);
				
				connected_device++;
				break;
				
			case network_type_disconnect :
				var _txt = $"Websocket server: Client disconnected at port {port} on node {display_name}";
				noti_status(_txt, noone, self);
				
				connected_device--;
				break;
				
			case network_type_data :
				var _buffer = async_load[? "buffer"];
				var _socket = async_load[? "id"];
				var data    = buffer_get_string(_buffer);
				
				var _data = json_try_parse(data, noone);
				if(_data == noone)	_data = { rawData: new Buffer(_buffer) }
				else				buffer_delete(_buffer);
					
				outputs[0].setValue(_data);
				network_trigger = true;
				break;
		}
	}
	
	static step = function() {
		var _mode = getInputData(2);
		
		inputs[3].setVisible(_mode == 0);
		
		if(network_trigger == 1) {
			outputs[1].setValue(1);
			network_trigger = -1;
			
		} else if(network_trigger == -1) {
			outputs[1].setValue(0);
			network_trigger = 0;
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(project.online) return false;
		
		if(CLONING) return;
		setPort();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var _active = getInputData(1);
		var bbox    = drawGetBbox(xx, yy, _s);
		var network = ds_map_try_get(NETWORK_SERVERS, port, noone);
		
		var cc = CDEF.red, aa = 1;
		if(network >= 0) cc = CDEF.lime;
		if(!_active) aa = 0.5;
		
		var _y0 = bbox.y0 + ui(16);
		var _y1 = bbox.y1 - ui(16);
		var _ts = _s * 0.75;
		
		draw_set_text(f_code, fa_center, fa_top, COLORS._main_text, 0.75);
		draw_text_add(bbox.xc, bbox.y0, $"Port {port}", _ts);
		
		draw_set_valign(fa_bottom)
		draw_text_add(bbox.xc, bbox.y1, $"{connected_device} " + __txt("Connected"), _ts);
		
		draw_set_alpha(1);
		
		draw_sprite_fit(THEME.node_websocket_receive, 0, bbox.xc, (_y0 + _y1) / 2, bbox.w, _y1 - _y0, cc, aa);
	}
}