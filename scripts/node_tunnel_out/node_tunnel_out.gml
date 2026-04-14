#region create
	function Node_create_Tunnel_Out(_x, _y, _group = noone, _param = {}) {
		var node = new Node_Tunnel_Out(_x, _y, _group);
		var quer = _param[$ "query"]; 
		var query = (is_struct(quer) && quer[$ "type"] == "value"? quer[$ "value"] : "") ?? "";
		
		if(query != "") node.inputs[0].skipDefault().setValue(query);
		return node;
	}
	
#endregion

function Node_Tunnel_Out(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tunnel Receiver";
	color = COLORS.node_blend_tunnel;
	renderAll    = true;
	preview_draw = false;
	set_default  = false;
	
	setDimension(32, 32);
	
	newInput(0, nodeValue_Text("Name", LOADING || APPENDING? "" : $"tunnel{struct_size(project.tunnels_out)}" ))
		.rejectArray().setAnimable(false);
	
	////- =Display
	newInput(1, nodeValue_EButton( "Label Position", 0, [ "T", "B", "L", "R" ] ));
	newInput(2, nodeValue_Float(   "Label Scale",    1 ));
	newInput(3, nodeValue_Color(   "Label Color",    cola(COLORS._main_text) ));
	newInput(4, nodeValue_Slider(  "Label Alpha",    1 ));
	
	// input 5
	
	newOutput(0, nodeValue_Output("Value out", VALUE_TYPE.any, noone ));
	
	input_display_list = [ 0, 
		["Display", false], 1, 2, 3, 4, 
	];
	
	inputs[0].getEditWidget().autocomplete_server = tunnel_autocomplete_server;
	inputs[0].getEditWidget().autocomplete_subt   = "Ctrl: Change connected";
	inputs[0].is_modified = true;
	inputs[0].onSetValue  = function(newKey, oldValue) /*=>*/ {
		if(!key_mod_press(CTRL)) return;
		
		var nodes = project.tunnels_in[$ __key];
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var node = nodes[i];
			if(!is(node, Node_Tunnel_In) || node.__key != __key) continue;
			if(node.scope == 1 && node.group != group)           continue;
			
			node.inputs[0].setValueDirect(newKey);
		}
	};
	
	static getDisplayName = function() /*=>*/ {return string(inputs[0].getValue())};
	
	isHovering     = false;
	
	preview_connecting = false;
	junction_hover     = false;
	
	label_ori   = 0;
	label_scale = 1;
	label_color = ca_white;
	label_alpha = 1;
	
	__key = noone;
	__hov = undefined;
	
	////- Update
	
	insp1button = button(function() /*=>*/ { dialogPanelCall(new Panel_Tunnels()); }).setTooltip(__txt("Tunnel Panel"))
		.setIcon(THEME.tunnel_panel, 0, c_white).iconPad(ui(6))
		.setBaseSprite(THEME.button_hide_fill);
	
	insp2button = button(function() /*=>*/ { 
		var _key = inputs[0].getValue();
		if(!has(project.tunnels_in, _key)) return;
		
		var nodes = project.tunnels_in[$ _key];
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var node = nodes[i];
			if(!is(node, Node_Tunnel_In) || node.__key != __key) continue;
			if(node.scope == 1 && node.group != group)           continue;
			
			graphFocusNode(node);
		}
		
	}).setTooltip(__txt("Goto Sender"))
		.setIcon(THEME.tunnel, 1, c_white).iconPad(ui(6))
		.setBaseSprite(THEME.button_hide_fill);
	
	static update = function(frame = CURRENT_FRAME) {
		label_ori   = getInputData(1);
		label_scale = getInputData(2);
		label_color = getInputData(3);
		label_alpha = getInputData(4);
		
		__key = inputs[0].getValue();
		
		if(has(project.tunnels_in, __key)) {
			var nodes = project.tunnels_in[$ __key];
			for( var i = 0, n = array_length(nodes); i < n; i++ ) {
				var node = nodes[i];
				if(!is(node, Node_Tunnel_In) || node.__key != __key) continue;
				if(node.scope == 1 && node.group != group)           continue;
				
				var _inputVal = node.inputs[1];
				
				outputs[0].setType(_inputVal.type);
				outputs[0].setDisplay(_inputVal.display_type);
				outputs[0].setValue(_inputVal.getValue());
			}
			
		} else {
			outputs[0].setType(VALUE_TYPE.any);
			outputs[0].setDisplay(VALUE_DISPLAY._default);
		}
		
		outputs[0].updateColor();
	}
	
	static onGetPreviousNodes = function(p) /*=>*/ { 
		if(!has(project.tunnels_in, __key)) return;
		
		var nodes = project.tunnels_in[$ __key];
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var node = nodes[i];
			if(!is(node, Node_Tunnel_In) || node.__key != __key) continue;
			if(node.scope == 1 && node.group != group)           continue;
			
			array_push(p, node); 
		}
	}
	
	////- Draw
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		return point_in_circle(_mx, _my, xx, yy, _s * 24);
	}
	
	static preDraw = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		inputs[0].x = xx;
		inputs[0].y = yy;
		
		outputs[0].x = xx;
		outputs[0].y = yy;
	}
	
	static drawBadge = function(_x, _y, _s) {}
	static drawJunctionNames = function(_x, _y, _mx, _my, _s, _panel = noone) {}
	
	static drawNodeBehind = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		var tun   = findPanel("Panel_Tunnels");
		var hover = isHovering || (tun && tun.tunnel_hover == self);
		if(!hover) return;
		
		if(!has(project.tunnels_in, __key)) return;
		
		var nodes = project.tunnels_in[$ __key];
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var node = nodes[i];
			if(!is(node, Node_Tunnel_In) || node.__key != __key) continue;
			if(node.group != group) continue;
			
			preview_connecting      = true;
			node.preview_connecting = true;
			
			draw_set_color(outputs[0].color_display);
			draw_set_alpha(0.5);
			
			var frx = _x +  node.x      * _s;
			var fry = _y + (node.y + 8) * _s;
			draw_line_dotted(frx, fry, xx, yy, 2 * _s, 0, 3);
			
			draw_set_alpha(1);
		}
	}
	
	static checkJunctions = function(_x, _y, _mx, _my, _s, _fast = false) {
		var _hov = point_in_circle(_mx, _my, _x, _y, _s * 24);
		if(__hov != _hov) PANEL_GRAPH.refreshDraw();
		__hov = _hov;
		
		if(!_hov) { isHovering = false; return noone; }
		
		var _dy = junction_draw_hei_y * _s / 2;
		var _dx = _fast? 6  * _s : _dy;
		
		isHovering = outputs[0].isHovering(_s, _dx, _dy, _mx, _my);
		if(!isHovering) CURSOR_SPRITE = THEME.view_pan;
		
		return isHovering? outputs[0] : noone;
	}
	
	static drawJunctionsFast = function(_x, _y, _mx, _my, _s) {
		var s1 = _s * 1.5, s4 = _s * 4.0;
		var jun = inputs[1];
		
		draw_set_color(jun.custom_color ?? jun.draw_fg);
		draw_rectangle(jun.x - s1, jun.y - s4, jun.x + s1, jun.y + s4, false);
	}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) {
		gpu_set_tex_filter(true);
		junction_hover = outputs[0].drawJunction(_s, _mx, _my);
		gpu_set_tex_filter(false);
	}
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		#region draw arc
			preview_connecting = false;
			
			shader_set(sh_node_arc);
				shader_set_color("color", outputs[0].color_display, .5);
				shader_set_f("angle", degtorad(-90));
				
				var _r = _s * 20;
				shader_set_f("amount", 0.4, 0.5);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
				var _r = _s * 30;
				shader_set_f("amount", 0.45, 0.525);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
				var _r = _s * 40;
				shader_set_f("amount", 0.475, 0.55);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
			shader_reset();
		#endregion
			
		var _r = _s * 16;
		if(active_draw_index > -1) {
			active_draw_index = -1;
			draw_circle_ui(xx, yy, _r, .03, COLORS._main_accent, 1);
			
		} else if(__hov && !isHovering) 
			draw_circle_ui(xx, yy, _r, .03, COLORS._main_accent, .75);
		
		var aa = label_alpha * _color_get_alpha(label_color);
		var ss = _s * .2 * label_scale;
		var tt = string(inputs[0].getValue());
		
		switch(label_ori) {
			case 0 : draw_set_text(f_sdf, fa_center, fa_bottom, label_color, aa);
				     draw_text_transformed(xx, yy - 12 * _s, tt, ss, ss, 0); break;
				
			case 1 : draw_set_text(f_sdf, fa_center, fa_top, label_color, aa);
				     draw_text_transformed(xx, yy + 12 * _s, tt, ss, ss, 0); break;
				
			case 2 : draw_set_text(f_sdf, fa_right, fa_center, label_color, aa);
				     draw_text_transformed(xx - 12 * _s, yy, tt, ss, ss, 0); break;
				
			case 3 : draw_set_text(f_sdf, fa_left, fa_center, label_color, aa);
				     draw_text_transformed(xx + 12 * _s, yy, tt, ss, ss, 0); break;
		}
		
		draw_set_alpha(1);
	}
	
	static drawDimension = undefined;
	
}