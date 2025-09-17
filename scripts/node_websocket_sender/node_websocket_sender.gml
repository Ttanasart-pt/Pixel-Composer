function Node_Websocket_Sender(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Websocket Sender";
	
	newInput(0, nodeValue_Int("Port", 22800));
	
	newInput(1, nodeValue_Enum_Scroll("Data type",  0, [ "Struct", "Surface", "File", "Buffer" ]));
	
	newInput(2, nodeValue_Struct("Struct"));
	
	newInput(3, nodeValue_Surface("Surface"));
	
	newInput(4, nodeValue_Path("Path"))
		.setDisplay(VALUE_DISPLAY.path_load)
		.nonValidate();
	
	newInput(5, nodeValue_Text("Target", "127.0.0.1"));
	
	newInput(6, nodeValue_Buffer());
	
	input_display_list = [ 
		["Connection", false], 5, 0, 
		["Data",       false], 1, 2, 3, 4, 6 
	];
	
	port        = 0;
	url         = "";
	connected   = false;
	socket      = noone;
	callbackMap = {};
	
	attributes.network_timeout = 1000;
	array_push(attributeEditors, "Network");
	array_push(attributeEditors, [ "Connection timeout", function() /*=>*/ {return attributes.network_timeout}, 
		textBox_Number(function(val) /*=>*/ { setAttribute("network_timeout", val); network_set_config(network_config_connect_timeout, val); }) ]);
		
	setTrigger(1, __txt("Resend"), [ THEME.refresh_icon, 1, COLORS._main_value_positive ], function() /*=>*/ {return triggerRender()});
	
	static connectTo = function(newPort, newUrl) {
		if(project.online) return false;
		
		if(port == newPort && url == newUrl) return;
		if(socket != noone) network_destroy(socket);
		
		logNode($"Connecting to {newUrl}:{newPort}");
		
		if(ds_map_exists(PORT_MAP, port))
			array_remove(PORT_MAP[? port], self);
		
		port = newPort;
		url  = newUrl;
		
		if(ds_map_exists(NETWORK_CLIENTS, port)) 
			network_destroy(NETWORK_CLIENTS[? port]);
		
		var _sock = network_create_socket(network_socket_ws);
		if(_sock < 0) {
			noti_warning("Websocket sender: Fail to create new socket.", noone, self);
			return;
		}
		
		socket = _sock;
		logNode($"Connected to {newUrl}:{newPort}");
	}
	
	static sendCall = function(ID, params) {
		var network = ds_map_try_get(NETWORK_CLIENTS, ID, noone);
		if(network < 0) {
			noti_warning("Websocket sender: No client.", noone, self);
			return;
		}
		
		var content = params.content;
		var res = network_send_raw(network, content, buffer_get_size(content));
		if(res < 0) noti_warning("Websocket sender: Send error.", noone, self);
	}
	
	static asyncPackets = function(_async_load) {
		if(!active) return;
		
		var aid  = async_load[? "id"];
		var type = async_load[? "type"];
		
		if(type == network_type_non_blocking_connect) {
			noti_status($"Websocket sender: Connected at port {port} on node {display_name}", noone, self);
			
			connected = true;
			sendCall(aid, callbackMap[$ aid]);
		}
	}
	
	static step = function() {
		var _type = getInputData(1);
		
		inputs[2].setVisible(_type == 0, _type == 0);
		inputs[3].setVisible(_type == 1, _type == 1);
		inputs[4].setVisible(_type == 2, _type == 2);
		inputs[6].setVisible(_type == 3, _type == 3);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(project.online) return false;
		
		var _port   = getInputData(0);
		var _target = getInputData(5);
		
		var _type = getInputData(1);
		var _buff, res;
		var params = {};
		
		switch(_type) {
			case 0 :
				var _stru = getInputData(2);
				var _str  = json_stringify(_stru);
				_buff = buffer_from_string(_str);
				break;
				
			case 1 :
				var _surf = getInputData(3);
				if(!is_surface(_surf)) return;
				_buff = buffer_from_surface(_surf);
				break;
				
			case 2 :
				var _path = getInputData(4);
				if(!file_exists_empty(_path)) return;
				_buff = buffer_from_file(_path);
				break;
				
			case 3 :
				_buff = getInputData(6);
				if(!buffer_exists(_buff)) return;
				break;
		}
		
		params.content = _buff;
		connectTo(_port, _target);
		
		var _conId = network_connect_raw_async(socket, url, port);
		PORT_MAP[? _conId]        = self;
		callbackMap[$ _conId]     = params;
		NETWORK_CLIENTS[? _conId] = socket;
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox    = drawGetBbox(xx, yy, _s);
		var network = ds_map_try_get(NETWORK_CLIENTS, port, noone);
		
		var cc = CDEF.lime, aa = 1;
		
		var _y0 = bbox.y0 + ui(16);
		var _y1 = bbox.y1 - ui(16);
		var _ts = _s * 0.75;
		
		draw_set_text(f_code, fa_center, fa_top, COLORS._main_text);
		draw_set_alpha(0.75);
		draw_text_add(bbox.xc, bbox.y0, $"Port {port}", _ts);
		draw_set_alpha(1);
		
		draw_sprite_fit(THEME.node_websocket_send, 0, bbox.xc, (_y0 + _y1) / 2, bbox.w, _y1 - _y0, cc, aa);
	}
	
	static onCleanUp = function() {
		if(socket != noone) network_destroy(socket);
	}
		
	static postApplyDeserialize = function() {
		if(struct_has(attributes, "network_timeout")) network_set_config(network_config_connect_timeout, attributes.network_timeout);
	}
}