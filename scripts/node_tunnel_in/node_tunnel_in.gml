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
	
	inputs[| 0] = nodeValue("Name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" )
		.setDisplay(VALUE_DISPLAY.text_tunnel)
		.rejectArray();
		
	inputs[| 1] = nodeValue("Value in", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, noone )
		.setVisible(true, true);
	
	error_notification = noone;
	
	insp2UpdateTooltip = "Create tunnel out";
	insp2UpdateIcon    = [ THEME.tunnel, 0, c_white ];
	
	static onInspector2Update = function() { #region
		var _node = nodeBuild("Node_Tunnel_Out", x + 128, y);
		_node.inputs[| 0].setValue(getInputData(0));
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { onValueUpdate(); }
	
	static resetMap = function() { #region
		var _key = getInputData(0);
		TUNNELS_IN_MAP[? node_id] = _key;
		TUNNELS_IN[? _key] = inputs[| 1];
	} #endregion
	
	static checkDuplicate = function() { #region
		var _key = getInputData(0);
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
	} #endregion
	
	static onValueUpdate = function(index = -1) { #region
		var _key = getInputData(0);
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
	} #endregion
	
	static step = function() { #region
		var _key = getInputData(0);
		
		value_validation[VALIDATION.error] = error_notification != noone;
		
		if(inputs[| 1].isLeaf()) {
			inputs[| 1].setType(VALUE_TYPE.any);
			inputs[| 1].display_type = VALUE_DISPLAY._default;
		} else {
			inputs[| 1].setType(inputs[| 1].value_from.type);
			inputs[| 1].display_type = inputs[| 1].value_from.display_type;
		}
	} #endregion
	
	static getNextNodes = function() { #region
		var nodes = [];
		var nodeNames = [];
		var _key = getInputData(0);
		var amo = ds_map_size(TUNNELS_OUT);
		var k = ds_map_find_first(TUNNELS_OUT);
		
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"→→→→→ Call get next node from: {INAME}");
		LOG_BLOCK_START();
		
		repeat(amo) {
			if(TUNNELS_OUT[? k] == _key) {
				array_push(nodes, PROJECT.nodeMap[? k]);
				array_push(nodeNames, PROJECT.nodeMap[? k].internalName);
			}
			
			k = ds_map_find_next(TUNNELS_OUT, k);
		}
		
		LOG_IF(global.FLAG.render == 1, $"→→ Push {nodeNames} to queue.");
		
		LOG_BLOCK_END();
		LOG_BLOCK_END();
		return nodes;
	} #endregion
	
	/////////////////////////////////////////////////////////////////////////////
	
	static pointIn = function(_x, _y, _mx, _my, _s) { #region
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		return point_in_circle(_mx, _my, xx, yy, _s * 24);
	} #endregion
	
	static preDraw = function(_x, _y, _s) { #region
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		inputs[| 0].x = xx;
		inputs[| 0].y = yy;
		
		inputs[| 1].x = xx;
		inputs[| 1].y = yy;
	} #endregion
	
	static drawBadge = function(_x, _y, _s) {}
	static drawJunctionNames = function(_x, _y, _mx, _my, _s) {}
	
	static onDrawNodeBehind = function(_x, _y, _mx, _my, _s) { #region
		var xx = _x + x * _s;
		var yy = _y + y * _s;
		
		var hover = isHovering;
		var tun   = findPanel("Panel_Tunnels");
		hover |= tun && tun.tunnel_hover == self;
		if(!hover) return;
		
		var _key = getInputData(0);
		var amo  = ds_map_size(TUNNELS_OUT);
		var k    = ds_map_find_first(TUNNELS_OUT);
		
		draw_set_color(COLORS.node_blend_tunnel);
				
		repeat(amo) {
			if(TUNNELS_OUT[? k] == _key && ds_map_exists(PROJECT.nodeMap, k)) {
				var node = PROJECT.nodeMap[? k];
				if(node.group != group) continue;
				
				var tox = _x + node.x * _s;
				var toy = _y + node.y * _s;
				draw_line_dotted(xx, yy, tox, toy, 4 * _s, current_time / 10, 2);
			}
			
			k = ds_map_find_next(TUNNELS_OUT, k);
		}
		
	} #endregion
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) { #region
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		isHovering = point_in_circle(_mx, _my, xx, yy, _s * 24);
		
		var jhov = inputs[| 1].drawJunction(_s, _mx, _my);
		if(!isHovering) return noone;
		
		hover_scale_to = 1;
		return jhov? inputs[| 1] : noone;
	} #endregion
	
	static drawNode = function(_x, _y, _mx, _my, _s) { #region
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		hover_alpha = 0.5;
		if(active_draw_index > -1) {
			hover_alpha		  =  1;
			hover_scale_to	  =  1;
			active_draw_index = -1;
		}
		
		shader_set(sh_node_arc);
			shader_set_color("color", inputs[| 1].color_display, hover_alpha);
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
		draw_text_transformed(xx, yy - 12, string(getInputData(0)), _s * 0.4, _s * 0.4, 0);
		
		return drawJunctions(_x, _y, _mx, _my, _s);
	} #endregion
	
	static onClone = function() { onValueUpdate(0); }
	
	static postConnect = function() { onValueUpdate(0); }
	
	static onDestroy = function() { #region
		if(error_notification != noone)
			noti_remove(error_notification);
	} #endregion
}