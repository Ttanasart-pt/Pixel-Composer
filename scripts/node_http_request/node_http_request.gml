function Node_HTTP_request(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "HTTP";
	always_pad = true;
	setDimension(96, 72);
	
	newInput( 0, nodeValue_Text(    "Address" ));
	
	////- =Request
	newInput( 1, nodeValue_EScroll( "Type",  0, [ "GET", "POST", "PUT", "PATCH", "DELETE", "Custom" ] ));
	newInput( 3, nodeValue_Text(    "Method"  ))
	
	////- =Content
	newInput( 2, nodeValue_Text(    "Content" ))
	
	////- =Headers
	// 4
	
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.text, ""));
	
	headers_render_h = 0;
	headers_render   = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var bx = _x;
		var by = _y;
		
		var bs = ui(24);
		
		var bt = __txt("Add Key:Value Pair");
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, bt, THEME.add_16, 0, COLORS._main_value_positive) == 2) 
			createNewInput();
		bx += bs + ui(4);
			
		var amo = getInputAmount();
		
		var ss  = ui(24);
		var top = bs  + ui(4);
		var hh  = top + ui(4);
		var _yy = _y + top;
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _yy, _w, headers_render_h - top, COLORS.node_composite_bg_blend, 1);
		
		var  bb = THEME.button_hide_fill;
		var  bs = ss;
		
		var _x0 = _x  + ui(8);
		var _y0 = _yy + ui(8);
		
		var toDel = undefined;
		
		for( var i = 0; i < amo; i++ ) {
			var ind = input_fix_len + i * data_length;
			
			var jKey = inputs[ind + 0];
			var jVal = inputs[ind + 1];
			
			var wKey = jKey.getEditWidget();
			var wVal = jVal.getEditWidget();
			
			var key = getInputData(ind + 0);
			var val = getInputData(ind + 1);
			
			var xx = _x0;
			var ww = _w - ui(8);
			
			#region Right Buttons
				var bx = xx + ww - bs - ui(4);
				var by = _y0 + ss / 2 - bs / 2;
				
				if(buttonInstant_Pad(bb, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, CARRAY.button_negative, 1, ui(8)) == 2)
					toDel = ind;
				
				bx -= bs + ui(4);
				ww -= bs + ui(4);
				
				ww -= ui(4);
			#endregion
			
			var _wdw   = ww / 2 - ui(16);
			var _param = new widgetParam(xx, _y0, _wdw, ss, key, undefined, _m).setFont(f_p3).setFocusHover(_focus, _hover);
			wKey.drawParam(_param);
			
			var _param = new widgetParam(xx + _wdw + ui(16), _y0, _wdw, ss, val, undefined, _m).setFont(f_p3).setFocusHover(_focus, _hover);
			wVal.drawParam(_param);
			
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(xx + _wdw + ui(8), _y0 + ss / 2, ":");
			
			_y0 += ss + ui(4);
			 hh += ss + ui(4);
		}
		
		if(toDel != undefined) {
			array_delete(inputs, toDel, data_length);
			triggerRender();
		}
		
		headers_render_h = hh + ui(8);
		return hh + ui(8);
	});
	
	input_display_list = [  0,
		[ "Request", false ],  1,  3,  
		[ "Content", false ],  2, 
		[ "Headers", false ],  headers_render, 
	]
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index+0, nodeValue_Text( "Key"   ).setDisplay(VALUE_DISPLAY.text_box));
		newInput(index+1, nodeValue_Text( "Value" ).setDisplay(VALUE_DISPLAY.text_box));
		// 2
		
		postCreateNewInput(index);
		// refreshDynamicDisplay();
		return inputs[index];
	} 
	
	setDynamicInput(2, false);
	
	////- Node
	
	address_domain  = "";
	downloaded_size = 0;
	
	insp1button = button(function() /*=>*/ {return request()}).setTooltip(__txt("Send Request"))
		.setIcon(THEME.http_request_icon, 0, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	attributes.max_file_size = 10000;
	array_push(attributeEditors, "HTTP");
	array_push(attributeEditors, Node_Attribute("Max request size", function() /*=>*/ {return attributes.max_file_size}, function() /*=>*/ {return textBox_Number(function(v) /*=>*/ {return setAttribute("max_file_size", v)})}));
	
	static request = function() {
		if(project.online) return false;
		
		var _addr = getInputData( 0);
		var _type = getInputData( 1);
		var _cont = getInputData( 2);
		
		var _headers = ds_map_create();
		
		var _amo = getInputAmount();
		for( var i = 0; i < _amo; i++ ) {
			var _ind = input_fix_len + i * data_length;
			ds_map_add(_headers, getInputData(_ind+0), getInputData(_ind+1));
		}
			
		downloaded_size = 0;
		
		if(_type == 0) {
			// asyncCall(http_get(_addr), (param, data) => {
			asyncCall(http_request(_addr, "GET", _headers, _cont), function(param, data) /*=>*/ {
				var sta = data[? "status"];
				var res = data[? "result"];
				
				if(sta == 0) {
					if(downloaded_size > attributes.max_file_size) {
						noti_warning($"HTTP request: Requesed file to large ({downloaded_size} B).", noone, self);
						outputs[0].setValue("");
					} else
						outputs[0].setValue(res);
						
					triggerRender(true);
					
				} else if(sta == 1) {
					var _siz = data[? "contentLength"];
					var _dow = data[? "sizeDownloaded"];
					
					downloaded_size = _dow;
				}
			});
			
		} else {
			var _met = "";
			
			switch(_type) {
				case 1 : _met = "POST";   break;
				case 2 : _met = "PUT";    break;
				case 3 : _met = "PATCH";  break;
				case 4 : _met = "DELETE"; break;
				case 5 : _met = getInputData( 3); break;
			}
			
			asyncCall(http_request(_addr, _met, _headers, _cont), function(param, data) /*=>*/ {
				var sta = data[? "status"];
				var res = data[? "result"];
				
				outputs[0].setValue(res);
				triggerRender(true);
			});
		}
		
		ds_map_destroy(_headers);
	}
	
	static update = function() {
		if(project.online) return false;
		
		#region data
			var _addr = getInputData( 0);
			var _type = getInputData( 1);
			
			var _sCont = _type > 0;
			
			inputs[ 3].setVisible(_type == 5);
			inputs[ 2].setVisible(_sCont, _sCont);
		#endregion
		
		if(_addr == "") return;
		
		draw_set_font(f_p0);
		var _addrs = string_split(_addr, "/", true);
		address_domain = array_safe_get(_addrs, 1, "");
		address_domain = string_cut_line(address_domain, 128);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var addr = getInputData(0);
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, address_domain);
	}
}