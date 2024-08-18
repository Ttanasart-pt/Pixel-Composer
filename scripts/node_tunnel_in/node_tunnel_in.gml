function Node_Tunnel_In(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tunnel In";
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
	if(!LOADING && !APPENDING) tname = $"tunnel{ds_map_size(TUNNELS_IN_MAP)}";
	
	newInput(0, nodeValue_Text("Name", self, tname ))
		.rejectArray();
		
	newInput(1, nodeValue("Value in", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, noone ))
		.setVisible(true, true);
	
	error_notification = noone;
	
	insp2UpdateTooltip = "Create tunnel out";
	insp2UpdateIcon    = [ THEME.tunnel, 0, c_white ];
	
	static onInspector2Update = function() {
		var _node = nodeBuild("Node_Tunnel_Out", x + 128, y);
		_node.inputs[0].setValue(inputs[0].getValue());
	}
	
	static update = function(frame = CURRENT_FRAME) { onValueUpdate(); }
	
	static resetMap = function() {
		var _key = inputs[0].getValue();
		TUNNELS_IN_MAP[? node_id] = _key;
		TUNNELS_IN[? _key] = inputs[1];
	} resetMap();
	
	static checkDuplicate = function() {
		var _key = inputs[0].getValue();
		var amo  = ds_map_size(TUNNELS_IN_MAP);
		var k    = ds_map_find_first(TUNNELS_IN_MAP);
		var dup  = false;
		
		repeat(amo) {
			if(k != node_id && TUNNELS_IN_MAP[? k] == _key)
				dup = true;
			
			k = ds_map_find_next(TUNNELS_IN_MAP, k);
		}
		
		if(dup && error_notification == noone) {
			error_notification = noti_error("Duplicated key: " + string(_key));
			error_notification.onClick = function() { PANEL_GRAPH.focusNode(self); };
		} else if(!dup && error_notification) {
			noti_remove(error_notification);
			error_notification = noone;
		}
	}
	
	static onValueUpdate = function(index = -1) {
		var _key = inputs[0].getValue();
		resetMap();
		
		var amo = ds_map_size(TUNNELS_IN_MAP);
		var k   = ds_map_find_first(TUNNELS_IN_MAP);
		repeat(amo) {
			if(ds_map_exists(PROJECT.nodeMap, k) && struct_has(PROJECT.nodeMap[? k], "resetMap")) 
				PROJECT.nodeMap[? k].resetMap();
			k = ds_map_find_next(TUNNELS_IN_MAP, k);	
		}
		
		var k   = ds_map_find_first(TUNNELS_IN_MAP);
		repeat(amo) {
			if(ds_map_exists(PROJECT.nodeMap, k) && struct_has(PROJECT.nodeMap[? k], "checkDuplicate")) 
				PROJECT.nodeMap[? k].checkDuplicate();
			k = ds_map_find_next(TUNNELS_IN_MAP, k);	
		}
		
		if(index == 0) { RENDER_ALL_REORDER }
	}
	
	static step = function() {
		var _key = inputs[0].getValue();
		
		value_validation[VALIDATION.error] = error_notification != noone;
		
		if(inputs[1].value_from == noone) {
			inputs[1].setType(VALUE_TYPE.any);
			inputs[1].display_type = VALUE_DISPLAY._default;
		} else {
			inputs[1].setType(inputs[1].value_from.type);
			inputs[1].display_type = inputs[1].value_from.display_type;
		}
	}
	
	static getNextNodes = function() {
		var nodes = [];
		var nodeNames = [];
		var _key = inputs[0].getValue();
		var amo  = ds_map_size(TUNNELS_OUT);
		var k    = ds_map_find_first(TUNNELS_OUT);
		
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"→→→→→ Call get next node from: {INAME}");
		
		repeat(amo) {
			if(TUNNELS_OUT[? k] == _key) {
				array_push(nodes, PROJECT.nodeMap[? k]);
				array_push(nodeNames, PROJECT.nodeMap[? k].internalName);
			}
			
			k = ds_map_find_next(TUNNELS_OUT, k);
		}
		
		LOG_IF(global.FLAG.render == 1, $"→→ Push {nodeNames} to queue.");
		
		LOG_BLOCK_END();
		return nodes;
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
		
		inputs[0].x = xx;
		inputs[0].y = yy;
		
		inputs[1].x = xx;
		inputs[1].y = yy;
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
		
		var _key  = inputs[0].getValue();
		var _keys = ds_map_keys_to_array(TUNNELS_OUT);
		
		draw_set_color(inputs[1].color_display);
		draw_set_alpha(0.5);
		
		for (var i = 0, n = array_length(_keys); i < n; i++) {
			var _k = _keys[i];
			
			if(TUNNELS_OUT[? _k] != _key) continue;
			if(!ds_map_exists(PROJECT.nodeMap, _k)) continue;
			
			var node = PROJECT.nodeMap[? _k];
			if(node.group != group) continue;
			
			preview_connecting      = true;
			node.preview_connecting = true;
			
			var tox = _x + node.x * _s;
			var toy = _y + node.y * _s;
			draw_line_dotted(xx, yy, tox, toy, 2 * _s, current_time / 10, 3);
		}
		
		draw_set_alpha(1);
	}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		isHovering = point_in_circle(_mx, _my, xx, yy, _s * 24);
		
		var jhov = inputs[1].drawJunction(_s, _mx, _my);
		if(!isHovering) return noone;
		
		hover_scale_to = 1;
		return jhov? inputs[1] : noone;
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
				shader_set_color("color", inputs[1].color_display, hover_alpha);
				shader_set_f("angle", degtorad(90));
				
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
		draw_text_transformed(xx, yy - 12 * _s, string(inputs[0].getValue()), _s * .3, _s * .3, 0);
		
		return drawJunctions(_x, _y, _mx, _my, _s);
	}
	
	static onClone = function() { onValueUpdate(0); }
	
	static postConnect = function() { step(); onValueUpdate(0); }
	
	static onDestroy = function() {
		if(error_notification != noone)
			noti_remove(error_notification);
	}
}