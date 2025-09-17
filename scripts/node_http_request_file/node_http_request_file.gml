function Node_HTTP_Request_File(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "HTTP Download";
	
	newInput(0, nodeValue_Text("Address"));
	
	newInput(1, nodeValue_Enum_Scroll("Format", 0, [ "Image" ]));
	
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.surface, noone));
	
	attributes.temp_path = TEMPDIR + UUID_generate();
	spr = noone;
	
	current_addr    = "";
	address_domain  = "";
	downloaded_size = 0;
	downloading     = false;
	
	setTrigger(1, "Trigger", [ THEME.sequence_control, 1, COLORS._main_value_positive ], function() /*=>*/ {return request()});
	
	static request = function() {
		if(project.online) return false;
		
		var _addr = getInputData(0);
		downloaded_size = 0;
		
		var spl = string_split(_addr, "/");
		attributes.temp_path = array_last(spl);
		
		asyncCall(http_get_file(_addr, attributes.temp_path), function(param, data) /*=>*/ {
			var sta = data[? "status"];
			var pth = data[? "result"];
			
			if(sta == 0) {
			    var _form = getInputData(1);
			    
				attributes.temp_path = pth;
				if(_form == 0 && file_exists_empty(pth) && file_is_image(pth)) {
				    if(sprite_exists(spr)) sprite_delete(spr);
				    spr = sprite_add(pth, 0, false, false, 0, 0);
				}
				
				downloading = false;
				triggerRender(true);
				
			} else if(sta == 1) {
				var _siz = data[? "contentLength"];
				var _dow = data[? "sizeDownloaded"];
				
				downloaded_size = _dow;
			}
		});
		
		downloading  = true;
		current_addr = _addr;
	}
	
	static update = function() {
		if(project.online) return false;
		
		var _addr = getInputData(0);
	    var _form = getInputData(1);
	    
		if(_addr == "") return;
	    if(current_addr != _addr) request();
	    
		if(_form == 0 && sprite_exists(spr)) {
    		var _osurf = outputs[0].getValue();
    		surface_free_safe(_osurf);
    		
    		var _surf = surface_create_from_sprite(spr);
    	    outputs[0].setValue(_surf);
		}
		
		draw_set_font(f_p0);
		var _addrs = string_split(_addr, "/", true);
		address_domain = array_safe_get(_addrs, 1, "");
		address_domain = string_cut_line(address_domain, 128);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(downloading) draw_sprite_ui(THEME.loading, 0, xx + w * _s / 2, yy + h * _s / 2, _s, _s, current_time / 2, COLORS._main_icon, 1);
	}
	
}