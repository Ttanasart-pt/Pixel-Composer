function Node_Tunnel_In(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tunnel Sender";
	color = COLORS.node_blend_tunnel;
	renderAll    = true;
	preview_draw = false;
	set_default  = false;
	
	setDimension(32, 32);
	
	newInput( 0, nodeValue_Text( "Name", LOADING || APPENDING? "" : $"tunnel{struct_size(project.tunnels_in)}" ))
		.rejectArray().setAnimable(false);
	newInput( 1, nodeValue_Any( "Value in" )).setVisible(true, true);
	
	////- =Display
	newInput( 2, nodeValue_EButton( "Label Position", 0, [ "T", "B", "L", "R" ] ));
	newInput( 3, nodeValue_Float(   "Label Scale",    1        ));
	newInput( 4, nodeValue_Color(   "Label Color",    ca_white ));
	newInput( 5, nodeValue_Slider(  "Label Alpha",    1        ));
	
	////- =Scope
	newInput( 6, nodeValue_EButton( "Scope", 1, [ "Global", "Group" ] ));
	// input 7
	
	input_display_list = [ 0, 1, 
		[ "Display", false ], 2, 3, 4, 5, 
		[ "Scope",   false ], 6, 
	];
	
	inputs[0].getEditWidget().autocomplete_server = tunnel_autocomplete_server;
	inputs[0].getEditWidget().autocomplete_subt   = "Ctrl: Change connected";
	inputs[0].is_modified = true;
	inputs[0].onSetValue  = function(newKey, oldValue) /*=>*/ {
		if(!key_mod_press(CTRL)) return;
		
		var _rec = project.tunnels_out[$ __key];
		if(!is_array(_rec)) return;
		
		for( var i = 0, n = array_length(_rec); i < n; i++ )
			_rec[i].inputs[0].setValueDirect(newKey);
	};
	
	static getDisplayName = function() /*=>*/ {return string(inputs[0].getValue())};
	
	isHovering     = false;
	
	preview_connecting = false;
	junction_hover     = false;
	error_notification = noone;
	
	label_ori   = 0;
	label_scale = 1;
	label_color = ca_white;
	label_alpha = 1;
	open        = true;
	scope       = 1;
	
	__jfrom = noone;
	__key   = noone;
	__hov   = undefined;
	
	////- Update
	
	insp1button = button(function() /*=>*/ { dialogPanelCall(new Panel_Tunnels()); }).setTooltip(__txt("Tunnel Panel"))
		.setIcon(THEME.tunnel_panel, 0, c_white).iconPad(ui(6))
		.setBaseSprite(THEME.button_hide_fill);
	
	insp2button = button(function() /*=>*/ { 
		var _nx = x + 160;
		var _ny = y;//PANEL_GRAPH.getFreeY(_nx, y);
		    
		var _node = nodeBuild("Node_Tunnel_Out", _nx, _ny);
		    _node.skipDefault();
		if(!is(_node, Node)) return;
		
		var _key = inputs[0].getValue();
		_node.inputs[0].setValue(_key);
		
	}).setTooltip(__txt("Create Receiver"))
		.setIcon(THEME.tunnel, 0, c_white).iconPad(ui(6))
		.setBaseSprite(THEME.button_hide_fill);
	
	static update = function(frame = CURRENT_FRAME) {
		var _frm = inputs[1].value_from;
		
		label_ori   = getInputData(2);
		label_scale = getInputData(3);
		label_color = getInputData(4);
		label_alpha = getInputData(5);
		scope       = getInputData(6);
		
		if(_frm != __jfrom) {
			inputs[1].setType(   _frm? _frm.type         : VALUE_TYPE.any);
			inputs[1].setDisplay(_frm? _frm.display_type : VALUE_DISPLAY._default);
			inputs[1].updateColor();
		}
		
		__jfrom = _frm;
		
		value_validation[VALIDATION.error] = error_notification != noone;
	}
	
	static getNextNodes = function(checkLoop = false) {
		var _key  = inputs[0].getValue();
		var nodes = project.tunnels_out[$ _key];
		if(!array_valid(nodes)) return [];
		
		if(scope == 1) return array_filter(nodes, function(n,i) /*=>*/ {return is(n, Node) && n.group == group});
		return array_filter(nodes, function(n,i) /*=>*/ {return is(n, Node)});
	}
	
	static forwardPassiveDynamic = function() {
		rendered = false;
		var nextNodes = getNextNodes();
		
		for( var i = 0, n = array_length(nextNodes); i < n; i++ ) {
			nextNodes[i].passiveDynamic = true;
			nextNodes[i].rendered       = false;
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
		
		inputs[1].x = xx;
		inputs[1].y = yy;
	}
	
	static drawBadge = function(_x, _y, _s) {}
	static drawJunctionNames = function(_x, _y, _mx, _my, _s, _panel = noone) {}
	
	static drawNodeBehind = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		var tun   = findPanel("Panel_Tunnels");
		var hover = isHovering || (tun && tun.tunnel_hover == self);
		if(!hover) return;
		
		var _key  = inputs[0].getValue();
		var _outs = project.tunnels_out[$ _key];
		if(!is_array(_outs)) return;
		
		draw_set_color(inputs[1].color_display);
		draw_set_alpha(0.5);
		
		for (var i = 0, n = array_length(_outs); i < n; i++) {
			var _n = _outs[i];
			if(_n.group != group) continue;
			
			preview_connecting    = true;
			_n.preview_connecting = true;
			
			var tox = _x +  _n.x      * _s;
			var toy = _y + (_n.y + 8) * _s;
			draw_line_dotted(xx, yy, tox, toy, 2 * _s, 0, 3);
		}
		
		draw_set_alpha(1);
	}
	
	static checkJunctions = function(_x, _y, _mx, _my, _s, _fast = false) {
		var _hov = point_in_circle(_mx, _my, _x, _y, _s * 24);
		if(__hov != _hov) PANEL_GRAPH.refreshDraw();
		__hov = _hov;
		
		if(!_hov) { isHovering = false; return noone; }
		
		var _dy = junction_draw_hei_y * _s / 2;
		var _dx = _fast? 6  * _s : _dy;
		
		isHovering = inputs[1].isHovering(_s, _dx, _dy, _mx, _my);
		if(!isHovering) CURSOR_SPRITE = THEME.view_pan;
		
		return isHovering? inputs[1] : noone;
	}
	
	static drawJunctionsFast = function(_x, _y, _mx, _my, _s) {
		var s1 = _s * 1.5, s4 = _s * 4.0;
		var jun = inputs[1];
		
		draw_set_color(jun.custom_color ?? jun.draw_fg);
		draw_rectangle(jun.x - s1, jun.y - s4, jun.x + s1, jun.y + s4, false);
	}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) {
		gpu_set_tex_filter(true);
		junction_hover = inputs[1].drawJunction(_s, _mx, _my);
		gpu_set_tex_filter(false);
	}
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		#region draw arc
			preview_connecting = false;
			
			shader_set(sh_node_arc);
				shader_set_color("color", inputs[1].color_display, .5);
				shader_set_f("angle", degtorad(90));
				
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
	
	////- Actions
	
	static onDestroy = function() {
		if(error_notification != noone)
			noti_remove(error_notification);
	}
	
}