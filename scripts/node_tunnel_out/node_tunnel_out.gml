function Node_Tunnel_Out(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tunnel Out";
	color = COLORS.node_blend_tunnel;
	is_group_io  = true;
	preview_draw = false;
	
	setDimension(32, 32);
	
	isHovering     = false;
	hover_scale    = 0;
	hover_scale_to = 0;
	hover_alpha    = 0;
	
	preview_connecting = false;
	preview_scale = 1;
	
	var tname = "";
	if(!LOADING && !APPENDING && !ds_map_empty(TUNNELS_IN))
		tname = ds_map_find_first(TUNNELS_IN);
	
	inputs[| 0] = nodeValue("Name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, tname )
		.setDisplay(VALUE_DISPLAY.text_tunnel)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Value out", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, noone );
	
	insp2UpdateTooltip = "Goto tunnel in";
	insp2UpdateIcon    = [ THEME.tunnel, 1, c_white ];
	
	static onInspector2Update = function() {
		var _key = inputs[| 0].getValue();
		if(!ds_map_exists(TUNNELS_IN, _key)) return;
		
		var _node = TUNNELS_IN[? _key].node;
		graphFocusNode(_node);
	}
	
	static isRenderable = function() {
		var _key = inputs[| 0].getValue();
		if(!ds_map_exists(TUNNELS_IN, _key)) return false;
		
		return TUNNELS_IN[? _key].node.rendered;
	}
	
	static onValueUpdate = function(index = -1) {
		var _key = inputs[| 0].getValue();
		
		if(index == 0) { RENDER_ALL_REORDER }
	}
	
	static step = function() {
		var _key = inputs[| 0].getValue();
		TUNNELS_OUT[? node_id] = _key;
		
		if(ds_map_exists(TUNNELS_IN, _key)) {
			outputs[| 0].setType(TUNNELS_IN[? _key].type);
			outputs[| 0].display_type = TUNNELS_IN[? _key].display_type;
		} else {
			outputs[| 0].setType(VALUE_TYPE.any);
			outputs[| 0].display_type = VALUE_DISPLAY._default;
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _key = inputs[| 0].getValue();
		
		if(ds_map_exists(TUNNELS_IN, _key))
			outputs[| 0].setValue(TUNNELS_IN[? _key].getValue());
	}
	
	/////////////////////////////////////////////////////////////////////////////
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		return point_in_circle(_mx, _my, xx, yy, _s * 24);
	}
	
	static preDraw = function(_x, _y, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		inputs[| 0].x = xx;
		inputs[| 0].y = yy;
		
		outputs[| 0].x = xx;
		outputs[| 0].y = yy;
	}
	
	static drawBadge = function(_x, _y, _s) {}
	static drawJunctionNames = function(_x, _y, _mx, _my, _s) {}
	
	static onDrawNodeBehind = function(_x, _y, _mx, _my, _s) {
		var xx = _x + x * _s;
		var yy = _y + y * _s;
		
		var hover = isHovering || hover_alpha == 1;
		var tun   = findPanel("Panel_Tunnels");
		hover |= tun && tun.tunnel_hover == self;
		if(!hover) return;
		
		var _key = inputs[| 0].getValue();
		if(!ds_map_exists(TUNNELS_IN, _key)) return;
		
		var node = TUNNELS_IN[? _key].node;
		if(node.group != group) return;
		
		preview_connecting      = true;
		node.preview_connecting = true;
		
		draw_set_color(outputs[| 0].color_display);
		draw_set_alpha(0.5);
		
		var frx = _x + node.x * _s;
		var fry = _y + node.y * _s;
		draw_line_dotted(frx, fry, xx, yy, 2 * _s, current_time / 10, 3);
		
		draw_set_alpha(1);
	}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		isHovering = point_in_circle(_mx, _my, xx, yy, _s * 24);
		
		var jhov = outputs[| 0].drawJunction(_s, _mx, _my);
		if(!isHovering) return noone;
		
		hover_scale_to = 1;
		return jhov? outputs[| 0] : noone;
	}
	
	static drawNode = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
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
				shader_set_color("color", outputs[| 0].color_display, hover_alpha);
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
		
		hover_scale    = lerp_float(hover_scale, hover_scale_to, 3);
		hover_scale_to = 0;
		
		draw_set_text(f_sdf, fa_center, fa_bottom, COLORS._main_text);
		draw_text_transformed(xx, yy - 12 * _s, string(inputs[| 0].getValue()), _s * .3, _s * .3, 0);
		
		return drawJunctions(_x, _y, _mx, _my, _s);
	}
	
	static onClone = function() { onValueUpdate(0); }
	
	static postConnect = function() { step(); onValueUpdate(0); }
}