function Panel_Custom_Button(_data) : Panel_Custom_Element(_data) constructor {
	type = "button";
	name = "Button";
	icon = THEME.panel_icon_element_button;
	
	software_action = "";
	
	bind_input  = new JuncLister(data, "Input",  CONNECT_TYPE.input);
	bind_action = new JuncLister(data, "Action", CONNECT_TYPE.input);
	bind_output = new JuncLister(data, "Output", CONNECT_TYPE.output);
	
	bg_output    = new JuncLister(data, "Idle",   CONNECT_TYPE.output, false, true);
	hover_output = new JuncLister(data, "Hover",  CONNECT_TYPE.output, false, true);
	press_output = new JuncLister(data, "Press",  CONNECT_TYPE.output, false, true);
	
	isSetValue = false;
	setValue   = 0;
	
	color = COLORS._main_icon;
	displayContent = false;
	
	#region functions
		software_function_name = [];
		software_function_key  = [];
		
		for( var i = 0, n = array_length(HOTKEY_CONTEXT); i < n; i++ ) {
			var cont = HOTKEY_CONTEXT[i];
			var hotk = HOTKEYS[$ cont];
			if(cont == "_" || string_starts_with(cont, "Node_")) continue;
			
			array_push(software_function_name, cont == 0? "> Global" : $"> {cont}");
			array_push(software_function_key,  -1);
			
			for( var j = 0, m = array_length(hotk); j < m; j++ ) {
				var _hot = hotk[j];
				if(_hot.fnObject == undefined) continue;
				
				array_push(software_function_name, _hot.name);
				array_push(software_function_key,  _hot.fnObject.fnName);
			}
			
			array_push(software_function_name, -1);
			array_push(software_function_key,  -1);
		}
	#endregion
	
	array_append(editors, [
		Simple_Editor("Software Action", new scrollBox( software_function_name, 
			function(i) /*=>*/ { 
				if(!is_real(i)) return;
				software_action = software_function_key[i]; 
			}).setFont(f_p2).setAlign(fa_left).setHorizontal(true).setPadding(ui(16)).setPaddingItem(ui(4)).setUpdateHover(false), 
				
			function( ) /*=>*/   {return software_action}, 
			function(t) /*=>*/ { software_action = t; }), 
		
		[ "Transfer Value", false ], 
		bind_output,
		bind_input,
		
		[ "Node Action", false ], 
		bind_action,
		
		[ "Set Value", false ], 
		Simple_Editor("Set Value", new checkBox( function() /*=>*/ { isSetValue = !isSetValue; } ), function() /*=>*/ {return isSetValue}, function(t) /*=>*/ { isSetValue = t; }), 
		Simple_Editor("Value", textArea_Number( function(t) /*=>*/ { setValue = t; } ), function() /*=>*/ {return setValue}, function(t) /*=>*/ { setValue = t; }), 
		
		[ "Display", false ], 
		Simple_Editor("Base Color",      new buttonColor( function(c) /*=>*/ { color = c; }).hideAlpha(), function() /*=>*/ {return color}, function(c) /*=>*/ { color = c; }), 
		Simple_Editor("Display Content", new checkBox( function() /*=>*/ { displayContent = !displayContent; }), function() /*=>*/ {return displayContent}, function(c) /*=>*/ { displayContent = c; }), 
		
		[ "Textures", false ], 
		bg_output,
		hover_output,
		press_output,
	]);
	
	////- Draw
	
	static draw = function(panel, _m) {
		input_junc  = bind_input.getJunction();
		action_junc = bind_action.getJunction();
		output_junc = bind_output.getJunction();
		
		var hov = elementHover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		var pre = hov && mouse_lclick(focus);
		
		var _bg_junc = bg_output.getJunction();
		
		if(_bg_junc) {
			var _ind = 0;
			var _dat = undefined;
			var _prs_junc = press_output.getJunction();
			var _hov_junc = hover_output.getJunction();
			var _targJunc = _bg_junc;
			
			     if(pre && _prs_junc) _targJunc = _prs_junc;
			else if(hov && _hov_junc) _targJunc = _hov_junc;
			else                      _targJunc = _bg_junc;
			
			if(hov) _ind = 1;
			if(pre) _ind = 2;
			
			     if(is(_targJunc, NodeValue))           draw_surface_stretched_safe(_targJunc.showValue(),       x, y, w, h, color);	
			else if(is(_targJunc, Panel_Custom_Sprite)) draw_sprite_stretched_ext_safe(_targJunc.getSpr(), _ind, x, y, w, h, color);	
			
		} else {
			draw_sprite_stretched_ext(THEME.box_r2, 0, x, y, w, h, color, 1);
			draw_sprite_stretched_add(THEME.box_r2, 0, x, y, w, h, color, pre * .2);
			draw_sprite_stretched_add(THEME.box_r2, 1, x, y, w, h, color, .2 + .3 * hov);
		}
		
		var _outVal = output_junc? output_junc.getValue() : undefined;
		
		if(hov && mouse_lpress(focus)) {
			if(software_action != "" && has(FUNCTIONS, software_action)) {
				var fn = FUNCTIONS[$ software_action];
				fn.action();
			}
			
			if(input_junc && output_junc) {
				if(input_junc.type == VALUE_TYPE.trigger)
					input_junc.setValue(true);
				
				if(action_junc) {
					var _val = input_junc.getValue();
					action_junc.setValue(_val);
				}
				Render();
				
				input_junc.setValue(_outVal);
			}
			
			if(isSetValue) input_junc.setValue(setValue);
		}
		
		if(displayContent && _outVal != undefined) {
			var pd = ui(4);
			var x0 = x + pd;
			var y0 = y + pd;
			var ww = w - pd * 2;
			var hh = h - pd * 2;
			
			switch(output_junc.type) {
				case VALUE_TYPE.surface  : draw_surface_stretched_safe(_outVal, x0, y0, ww, hh);         break;
				case VALUE_TYPE.color    : drawPalette(_outVal, x0, y0, ww, hh);                         break;
				case VALUE_TYPE.gradient : if(is(_outVal, gradientObject)) _outVal.draw(x0, y0, ww, hh); break;
				
			}
		}
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.bind = bind_input.serialize(_m);
		_m.actn = bind_action.serialize(_m);
		_m.acto = bind_output.serialize(_m);
		
		_m.bg    = bg_output.serialize(_m);
		_m.hover = hover_output.serialize(_m);
		_m.press = press_output.serialize(_m);
		
		_m.saction    = software_action;
		_m.isSetValue = isSetValue;
		_m.setValue   = setValue;
		
		_m.color          = color;
		_m.displayContent = displayContent;
		
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		bind_input.deserialize(_m.bind);
		bind_action.deserialize(_m.actn);
		bind_output.deserialize(_m.acto);
		
		if(has(_m, "bg"))    bg_output.deserialize(_m.bg);
		if(has(_m, "hover")) hover_output.deserialize(_m.hover);
		if(has(_m, "press")) press_output.deserialize(_m.press);
		
		software_action  = _m[$ "saction"]        ?? software_action;
		isSetValue       = _m[$ "isSetValue"]     ?? isSetValue;
		setValue         = _m[$ "setValue"]       ?? setValue;
		
		color            = _m[$ "color"]          ?? color;
		displayContent   = _m[$ "displayContent"] ?? displayContent;
		
		return self;
	}
}