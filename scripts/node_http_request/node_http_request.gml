function Node_HTTP_request(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "HTTP";
	setDimension(96, 72);
	
	inputs[| 0] = nodeValue("Address", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	inputs[| 1] = nodeValue_Enum_Scroll("Type", self,  0, [ "Get", "Post" ]);
	
	inputs[| 2] = nodeValue("Content", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
	
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	address_domain = "";
	
	static update = function() {
		var _addr = getInputData(0);
		var _type = getInputData(1);
		var _post = getInputData(2);
		
		inputs[| 2].setVisible(_type == 1, _type == 1);
		
		if(_addr == "") return;
		
		var _addrs = string_split(_addr, "/", true);
		address_domain = array_safe_get(_addrs, 1, "");
		draw_set_font(f_p0);
		address_domain = string_cut_line(address_domain, 128);
		
		switch(_type) {
			case 0 :
				asyncCall(http_get(_addr), function(param, data) /*=>*/ {
					var res = data[? "result"];
					outputs[| 0].setValue(res);
					triggerRender(false);
				});
				break;
			
			case 1 :
				asyncCall(http_post_string(_addr, _post), function(param, data) /*=>*/ {
					var res = data[? "result"];
					outputs[| 0].setValue(res);
					triggerRender(false);
				});
				break;
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var addr = getInputData(0);
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, address_domain);
	}
}