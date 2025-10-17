function Node_Tunnel_Out(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tunnel Receiver";
	color = COLORS.node_blend_tunnel;
	preview_draw = false;
	set_default  = false;
	
	setDimension(32, 32);
	
	newInput(0, nodeValue_Text("Name", LOADING || APPENDING? "" : ds_map_find_first(project.tunnels_in) )).rejectArray();
	
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
	
	inputs[0].editWidget.autocomplete_server = tunnel_autocomplete_server;
	inputs[0].editWidget.autocomplete_subt   = "Ctrl: Change connected";
	inputs[0].is_modified = true;
	inputs[0].onSetValue  = function(newKey) /*=>*/ {
		if(!key_mod_press(CTRL)) return;
		
		var node = project.tunnels_in[? __key].node;
		if(node.group != group || node.__key != __key) return;
		
		node.inputs[0].setValueDirect(newKey);
	};
	
	static getDisplayName = function() /*=>*/ {return string(inputs[0].getValue())};
	
	isHovering     = false;
	hover_scale    = 0;
	hover_scale_to = 0;
	hover_alpha    = 0;
	
	preview_connecting = false;
	preview_scale      = 1;
	junction_hover     = false;
	
	label_ori   = 0;
	label_scale = 1;
	label_color = ca_white;
	label_alpha = 1;
	
	__key = noone;
	
	////- Update
	
	setTrigger(1, "Tunnel Panel", [ THEME.tunnel_panel, 0, c_white ]);
	static onInspector1Update = function() { dialogPanelCall(new Panel_Tunnels()); }
	
	setTrigger(2, "Goto Sender", [ THEME.tunnel, 1, COLORS.node_blend_tunnel ]);
	static onInspector2Update = function() {
		var _key = inputs[0].getValue();
		if(!ds_map_exists(project.tunnels_in, _key)) return;
		
		var _node = project.tunnels_in[? _key].node;
		graphFocusNode(_node);
	}
	
	static onValueUpdate = function(index = -1) {
		resetMap();
		
		if(index == 0) { RENDER_ALL_REORDER }
	}
	
	static update = function(frame = CURRENT_FRAME) {
		
		label_ori   = getInputData(1);
		label_scale = getInputData(2);
		label_color = getInputData(3);
		label_alpha = getInputData(4);
		
		__key = inputs[0].getValue();
		
		if(ds_map_exists(project.tunnels_in, __key)) {
			var _inputNode = project.tunnels_in[? __key];
			
			outputs[0].setType(_inputNode.type);
			outputs[0].setDisplay(_inputNode.display_type);
			outputs[0].setValue(_inputNode.getValue());
			
		} else {
			outputs[0].setType(VALUE_TYPE.any);
			outputs[0].setDisplay(VALUE_DISPLAY._default);
		}
		
		outputs[0].updateColor();
	}
	
	static resetMap = function() {
		var _key = inputs[0].getValue();
		project.tunnels_out[? node_id] = _key;
	}
	
	static isRenderable = function() {
		var _key = inputs[0].getValue();
		if(!ds_map_exists(project.tunnels_in, _key)) return false;
		
		return project.tunnels_in[? _key].node.rendered;
	}
	
	static isActiveDynamic = function(frame = CURRENT_FRAME) { return false; }
	
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
	
	static onDrawNodeBehind = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		var hover = isHovering || hover_alpha == 1;
		var tun   = findPanel("Panel_Tunnels");
		hover = hover || (tun && tun.tunnel_hover == self);
		if(!hover) return;
		
		if(!ds_map_exists(project.tunnels_in, __key)) return;
		
		var node = project.tunnels_in[? __key].node;
		if(node.group != group) return;
		if(node.__key != __key) return;
		
		preview_connecting      = true;
		node.preview_connecting = true;
		insp2UpdateIcon[2]      = outputs[0].color_display;
		
		draw_set_color(outputs[0].color_display);
		draw_set_alpha(0.5);
		
		var frx = _x +  node.x      * _s;
		var fry = _y + (node.y + 8) * _s;
		draw_line_dotted(frx, fry, xx, yy, 2 * _s, current_time / 10, 3);
		
		draw_set_alpha(1);
	}
	
	static checkJunctions = function(_x, _y, _mx, _my, _s, _fast = false) {
		isHovering = point_in_circle(_mx, _my, _x, _y, _s * 24);
		if(!isHovering) return noone;
		hover_scale_to = 1;
		
		CURSOR_SPRITE = THEME.view_pan;
		var _dy = junction_draw_hei_y * _s / 2;
		var _dx = _fast? 6  * _s : _dy;
		if(outputs[0].isHovering(_s, _dx, _dy, _mx, _my)) return outputs[0];
		return noone;
	}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) {
		gpu_set_tex_filter(true);
		junction_hover = outputs[0].drawJunction(_s, _mx, _my);
		gpu_set_tex_filter(false);
	}
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		hover_alpha = 0.5;
		if(active_draw_index > -1) {
			hover_alpha		  =  1;
			hover_scale_to	  =  1;
			active_draw_index = -1;
		}
		
		#region draw arc
			var prev_s = preview_connecting? 1 + sin(current_time / 100) * 0.1 : 1;
			preview_scale      = lerp_float(preview_scale, prev_s, 5);
			preview_connecting = false;
			
			shader_set(sh_node_arc);
				shader_set_color("color", outputs[0].color_display, hover_alpha);
				shader_set_f("angle", degtorad(-90));
				
				var _r = preview_scale * _s * 20;
				shader_set_f("amount", 0.4, 0.5);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
				var _r = preview_scale * _s * 30;
				shader_set_f("amount", 0.45, 0.525);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
				var _r = preview_scale * _s * 40;
				shader_set_f("amount", 0.475, 0.55);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
			shader_reset();
		#endregion
			
		if(hover_scale > 0) {
			var _r = hover_scale * _s * 16;
			shader_set(sh_node_circle);
				shader_set_color("color", COLORS._main_accent, hover_alpha);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
			shader_reset();
		}
		
		hover_scale    = lerp_float(hover_scale, hover_scale_to && !junction_hover, 3);
		hover_scale_to = 0;
		
		var aa = label_alpha * _color_get_alpha(label_color);
		var ss = _s * .3 * label_scale;
		var tt = string(inputs[0].getValue());
		
		switch(label_ori) {
			case 0 : 
				draw_set_text(f_sdf, fa_center, fa_bottom, label_color, aa);
				draw_text_transformed(xx, yy - 12 * _s, tt, ss, ss, 0);
				break;
				
			case 1 : 
				draw_set_text(f_sdf, fa_center, fa_top, label_color, aa);
				draw_text_transformed(xx, yy + 12 * _s, tt, ss, ss, 0);
				break;
				
			case 2 : 
				draw_set_text(f_sdf, fa_right, fa_center, label_color, aa);
				draw_text_transformed(xx - 12 * _s, yy, tt, ss, ss, 0);
				break;
				
			case 3 : 
				draw_set_text(f_sdf, fa_left, fa_center, label_color, aa);
				draw_text_transformed(xx + 12 * _s, yy, tt, ss, ss, 0);
				break;
		}
		
		draw_set_alpha(1);
	}
	
	////- Actions
	
	static onClone = function() { onValueUpdate(0); }
	
	static postConnect = function() { onValueUpdate(0); }
	
	static onRestore = function() {
		resetMap();
	}
	
	////- Init
	
	resetMap();
	
}